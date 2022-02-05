//
//  PlaybackCore.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import AVFoundation
import Foundation
import LaceKit
import MediaPlayer
import ComposableArchitecture
import Combine
import UserActivityClient

struct PlaybackState: Equatable {
    enum PlayerState: Equatable {
        case playing, paused, stopped
    }

    var currentlyPlaying: MediaPlayable?
    var playerState: PlayerState = .stopped
    var currentActivity: NSUserActivity?
    var routePickerView: RoutePickerView?
}

enum PlaybackAction: Equatable {
    case loadPlayable(MediaPlayable)
    case pausePlayback
    case resumePlayback
    case stopPlayback
    case togglePlayback
    case updateNowPlaying
    case startMonitoringRemoteCommands
    case externalCommand(Result<ExternalCommandsClient.Action, Never>)
    case userActivity(Result<UserActivityClient.Action, Never>)
}

struct PlaybackEnvironment {
    // An intersting side effect of using TCA seems like you need to have these kind of persistent resources static
    // Maybe I'm just using it wrong?
    static var player: AVPlayer = {
        let player = AVPlayer()
        player.allowsExternalPlayback = false

        return player
    }()
    var mainQueue: DispatchQueue = .main
    var infoCenter = MPNowPlayingInfoCenter.default()
    var externalCommandsClient: ExternalCommandsClient = .live
    var appTileClient: AppTileClient = .live
    var userActivityClient: UserActivityClient = .live
}

let userActivityReducer = Reducer<PlaybackState, UserActivityClient.Action, PlaybackEnvironment>.combine(
    Reducer { state, action, enviornment in
        switch action {
        case let .willHandleActivity(activity):
            return .none
        case let .willNotHandleActivity(activity):
            return .none
        case let .becomeCurrentActivity(activity):
            activity.becomeCurrent()
            state.currentActivity = activity
            return .none
        case .resignCurrentActivity:
            state.currentActivity?.resignCurrent()
            state.currentActivity = nil
            return .none
        }
    }
)

let playbackReducer = Reducer<PlaybackState, PlaybackAction, PlaybackEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {
        case let .loadPlayable(playable):
            let item = AVPlayerItem(url: playable.streamURL)
            PlaybackEnvironment.player.pause()
            PlaybackEnvironment.player.replaceCurrentItem(with: item)
            PlaybackEnvironment.player.play()
            state.playerState = .playing
            environment.infoCenter.playbackState = .playing
            environment.appTileClient.updateAppTile(playable)

            #if os(macOS)
            state.routePickerView = RoutePickerView(routePickerButtonBordered: false, player: PlaybackEnvironment.player)
            #endif

            #if os(iOS)
            state.routePickerView = RoutePickerView(player: PlaybackEnvironment.player)
            #endif

            state.currentlyPlaying = playable
            return .merge(
                Effect(value: .updateNowPlaying),
                Effect(value: .startMonitoringRemoteCommands),
                environment.userActivityClient.becomeCurrent().catchToEffect(PlaybackAction.userActivity)
            )
        case .pausePlayback, .externalCommand(.success(.externalPauseTap)):
            PlaybackEnvironment.player.pause()
            state.playerState = .paused
            environment.infoCenter.playbackState = .paused
            return .none
        case .resumePlayback, .externalCommand(.success(.externalResumeTap)):
            PlaybackEnvironment.player.play()
            state.playerState = .playing
            environment.infoCenter.playbackState = .playing

            return .none
        case .stopPlayback:
            state.playerState = .stopped
            environment.infoCenter.playbackState = .stopped
            state.currentlyPlaying = nil
            PlaybackEnvironment.player.pause()
            PlaybackEnvironment.player.replaceCurrentItem(with: nil)
            return Effect(value: .updateNowPlaying)
        case .togglePlayback, .externalCommand(.success(.externalToggleTap)):
            switch state.playerState {
            case .paused:
                return Effect(value: .resumePlayback)
            case .playing:
                return Effect(value: .pausePlayback)
            case .stopped:
                return .none
            }
        case .updateNowPlaying:
            guard let nowPlaying = state.currentlyPlaying else {
                return .none
            }
            let updateInformation = [
                MPMediaItemPropertyTitle: nowPlaying.title,
                MPMediaItemPropertyArtist: "NTS",
                MPMediaItemPropertyComposer: nowPlaying.subtitle ?? "",
                MPNowPlayingInfoPropertyIsLiveStream: NSNumber(booleanLiteral: true),
                MPNowPlayingInfoPropertyAssetURL: nowPlaying.streamURL

            ] as [String : Any]

            environment.infoCenter.nowPlayingInfo = updateInformation
            return .none
        case .startMonitoringRemoteCommands:
            return environment.externalCommandsClient
                .startMonitoringCommands()
                .catchToEffect(PlaybackAction.externalCommand)
        case .externalCommand:
            return .none
        case let .userActivity(activity):
            print("Got action: \(activity)")
            return .none
        }
    }
)
