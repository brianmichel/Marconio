//
//  PlaybackCore.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import AppTileClient
import AVFoundation
import MediaPlayer
import ComposableArchitecture
import Combine
import UserActivityClient
import Models

public struct PlaybackState: Equatable {
    public enum PlayerState: Equatable {
        case playing, paused, stopped
    }

    public var currentlyPlaying: MediaPlayable? = nil
    public var playerState: PlayerState = .stopped
    public var currentActivity: NSUserActivity? = nil
    public var routePickerView: RoutePickerView? = nil
    public var monitoringRemoteCommands = false

    public init(currentlyPlaying: MediaPlayable? = nil,
         playerState: PlayerState = .stopped,
         currentActivity: NSUserActivity? = nil,
         routePickerView: RoutePickerView? = nil,
         monitoringRemoteCommands: Bool = false) {
        self.currentlyPlaying = currentlyPlaying
        self.playerState = playerState
        self.currentActivity = currentActivity
        self.routePickerView = routePickerView
        self.monitoringRemoteCommands = monitoringRemoteCommands
    }
}

public enum PlaybackAction: Equatable {
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

public struct PlaybackEnvironment {
    // An intersting side effect of using TCA seems like you need to have these kind of persistent resources static
    // Maybe I'm just using it wrong?
    public static var player: AVPlayer = {
        let player = AVPlayer()
        player.allowsExternalPlayback = true

        return player
    }()
    public var mainQueue: DispatchQueue = .main
    public var infoCenter = MPNowPlayingInfoCenter.default()
    public var externalCommandsClient: ExternalCommandsClient = .live
    public var appTileClient: AppTileClient = .live
    public var userActivityClient: UserActivityClient = .live

    public init(mainQueue: DispatchQueue = .main,
                infoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default(),
                externalCommandsClient: ExternalCommandsClient = .live,
                appTileClient: AppTileClient = .live,
                userActivityClient: UserActivityClient = .live) {
        self.mainQueue = mainQueue
        self.infoCenter = infoCenter
        self.externalCommandsClient = externalCommandsClient
        self.appTileClient = appTileClient
        self.userActivityClient = userActivityClient
    }
}

public let playbackReducer = Reducer<PlaybackState, PlaybackAction, PlaybackEnvironment>.combine(
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
            #else
            state.routePickerView = RoutePickerView(player: PlaybackEnvironment.player)
            #endif

            state.currentlyPlaying = playable
            return .merge(
                Effect(value: .updateNowPlaying),
                Effect(value: .startMonitoringRemoteCommands),
                environment.userActivityClient.becomeCurrent(playable).catchToEffect(PlaybackAction.userActivity)
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
            guard !state.monitoringRemoteCommands else {
                return .none
            }

            state.monitoringRemoteCommands = true

            return environment.externalCommandsClient
                .startMonitoringCommands()
                .catchToEffect(PlaybackAction.externalCommand)
        case .externalCommand:
            return .none
        case let .userActivity(.success(.becomeCurrentActivity(activity))):
            state.currentActivity = activity
            state.currentActivity?.becomeCurrent()
            return .none
        case .userActivity(.success(.willHandleActivity(_))):
            return .none
        }
    }
)

public extension PlaybackEnvironment {
    static var live: Self {
        return .init(mainQueue: .main,
                     infoCenter: .default(),
                     externalCommandsClient: .live,
                     appTileClient: .live,
                     userActivityClient: .live)
    }

    static var noop: Self {
        return .init(mainQueue: .main,
                     infoCenter: .default(),
                     externalCommandsClient: .noop,
                     appTileClient: .noop,
                     userActivityClient: .noop)
    }
}
