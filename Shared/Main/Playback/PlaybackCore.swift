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

struct PlaybackState: Equatable {
    enum PlayerState: Equatable {
        case playing, paused, stopped
    }

    var currentlyPlaying: MediaPlayable?
    var playerState: PlayerState = .stopped
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
}

struct PlaybackEnvironment {
    // An intersting side effect of using TCA seems like you need to have these kind of persistent resources static
    // Maybe I'm just using it wrong?
    static var player: AVPlayer = {
        let player = AVPlayer()
        player.allowsExternalPlayback = true

        return player
    }()
    var mainQueue: DispatchQueue = .main
    var infoCenter = MPNowPlayingInfoCenter.default()
    var externalCommandsClient: ExternalCommandsClient = .live
    var appTileClient: AppTileClient = .live
}

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

            state.currentlyPlaying = playable
            return .merge(
                Effect(value: .updateNowPlaying),
                Effect(value: .startMonitoringRemoteCommands)
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
        }
    }
)
