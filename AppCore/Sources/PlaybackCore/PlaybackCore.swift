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

public struct PlaybackReducer: ReducerProtocol {
    public enum Action: Equatable {
        case loadPlayable(MediaPlayable)
        case pausePlayback
        case resumePlayback
        case stopPlayback
        case togglePlayback
        case updateNowPlaying
        case startMonitoringRemoteCommands
        case externalCommand(Result<ExternalCommandsClient.Action, Never>)
        case userActivity(Result<UserActivityClient.Action, Never>)
        case playbackClient(Result<PlaybackClient.Action, Never>)
    }

    public struct State: Equatable {
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

    @Dependency(\.player) var player
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.infoCenter) var infoCenter
    @Dependency(\.externalCommandsClient) var externalCommandsClient
    @Dependency(\.appTileClient) var appTileClient
    @Dependency(\.userActivityClient) var userActivityClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .loadPlayable(playable):
                state.playerState = .playing
                infoCenter.playbackState = .playing
                appTileClient.updateAppTile(playable)

                state.currentlyPlaying = playable
                return .merge(
                    .send(.updateNowPlaying),
                    .send(.startMonitoringRemoteCommands),
                    userActivityClient.becomeCurrent(playable).catchToEffect(Action.userActivity),
                    player.play(playable.streamURL).catchToEffect(Action.playbackClient),
                    player.retreiveRoutes().catchToEffect(Action.playbackClient)
                )
            case .pausePlayback, .externalCommand(.success(.externalPauseTap)):
                state.playerState = .paused
                infoCenter.playbackState = .paused
                return player.pause().fireAndForget()
            case .resumePlayback, .externalCommand(.success(.externalResumeTap)):
                state.playerState = .playing
                infoCenter.playbackState = .playing
                return player.resume().fireAndForget()
            case .stopPlayback:
                state.playerState = .stopped
                infoCenter.playbackState = .stopped
                state.currentlyPlaying = nil
                return .merge(
                    player.stop().fireAndForget(),
                    .send(.updateNowPlaying)
                )
            case .togglePlayback, .externalCommand(.success(.externalToggleTap)):
                switch state.playerState {
                case .paused:
                    return .send(.resumePlayback)
                case .playing:
                    return .send(.pausePlayback)
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

                infoCenter.nowPlayingInfo = updateInformation
                return .none
            case .startMonitoringRemoteCommands:
                guard !state.monitoringRemoteCommands else {
                    return .none
                }

                state.monitoringRemoteCommands = true

                return externalCommandsClient
                    .startMonitoringCommands()
                    .catchToEffect(Action.externalCommand)
            case .externalCommand:
                return .none
            case let .userActivity(.success(.becomeCurrentActivity(activity))):
                state.currentActivity = activity
                state.currentActivity?.becomeCurrent()
                return .none
            case .userActivity(.success(.willHandleActivity(_))):
                return .none
            case let .playbackClient(.success(.receivedRoutes(routeView))):
                state.routePickerView = routeView
                return .none
            }
        }
    }
}

extension MPNowPlayingInfoCenter: DependencyKey {
    public static var liveValue: MPNowPlayingInfoCenter = .default()
}

extension DependencyValues {
    var infoCenter: MPNowPlayingInfoCenter {
        get { self[MPNowPlayingInfoCenter.self] }
        set { self[MPNowPlayingInfoCenter.self] = newValue }
    }
}
