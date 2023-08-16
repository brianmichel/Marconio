//
//  AppCore.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//
import AppDelegate
import ComposableArchitecture
import Foundation
import LaceKit
import Models
import DatabaseClient
import PlaybackCore

extension DependencyValues {
    var dbClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

struct AutoUpdatingChannelsId {}

public struct AppReducer: ReducerProtocol {
    public enum Action: Equatable {
        case loadInitialData
        case loadChannels
        case channelsResponse(Result<LiveBroadcastsResponse, RunnerError>)
        case loadMixtapes
        case mixtapesResponse(Result<MixtapesResponse, RunnerError>)
        case playback(PlaybackReducer.Action)
        case appDelegate(AppDelegateReducer.Action)
        case db(Result<DatabaseClient.Action, DatabaseClient.Error>)
        case settings(SettingsReducer.Action)
    }

    public struct State: Equatable {
        public var channels: [Channel] = []
        public var mixtapes: [Mixtape] = []
        public var playback: PlaybackReducer.State
        public var appDelegate: AppDelegateReducer.State
        public var settings: SettingsReducer.State

        public init(channels: [Channel] = [],
                    mixtapes: [Mixtape] = [],
                    playback: PlaybackReducer.State = .init(),
                    appDelegate: AppDelegateReducer.State = .init(),
                    settings: SettingsReducer.State = .init()) {
            self.channels = channels
            self.mixtapes = mixtapes
            self.playback = playback
            self.appDelegate = appDelegate
            self.settings = settings
        }
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.uuid) var uuid
    @Dependency(\.dbClient) var dbClient

    // TODO: Convert this to an actual client so it can be used as a dependency.
    var api: NTSAPI

    public init(api: NTSAPI = LiveAPI()) {
        self.api = api
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce(core)
        Scope(state: \.appDelegate, action: /Action.appDelegate, child: {
            AppDelegateReducer()
        })
        Scope(state: \.playback, action: /Action.playback, child: {
            PlaybackReducer()
        })
        Scope(state: \.settings, action: /Action.settings, child: {
            SettingsReducer()
        })
    }

    private func core(_ state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadInitialData:
            return .merge(
                dbClient
                    .startRealtimeUpdates()
                    .receive(on: mainQueue)
                    .catchToEffect(Action.db),

                    .concatenate(
                        try! api.live()
                            .receive(on: mainQueue)
                            .catchToEffect(Action.channelsResponse),
                        try! api.mixtapes()
                            .receive(on: mainQueue)
                            .catchToEffect(Action.mixtapesResponse)
                    )
            )
        case .loadChannels:
            return try! api.live()
                .receive(on: mainQueue)
                .catchToEffect(Action.channelsResponse)
        case let .channelsResponse(.success(channels)):
            return .concatenate(
                dbClient.writeChannels(channels.results).catchToEffect(Action.db),
                .send(.loadChannels)
                .deferred(for: .seconds(channels.nextUpdateInterval),
                          scheduler: mainQueue,
                          options: nil)
            )
        case let .channelsResponse(.failure(error)):
            // Do something with the error here
            print("unable to load channels: \(error)")
            return .none
        case .loadMixtapes:
            return try! api.mixtapes()
                .receive(on: mainQueue)
                .catchToEffect(Action.mixtapesResponse)
        case let .mixtapesResponse(.success(mixtapes)):
            return .concatenate(
                dbClient.writeMixtapes(mixtapes.results).catchToEffect(Action.db)
            )
        case let .mixtapesResponse(.failure(error)):
            // Do something with the error here
            print("unable to load mixtapes: \(error)")
            return .none
        case .playback:
            return .none
        case let .appDelegate(.continueActivity(activity)):
            if let mediaPlayable = activity.playable() {
                return .send(.playback(.loadPlayable(mediaPlayable)))
            }
            return .none
        case .appDelegate:
            return .none
        case .db(.failure(_)):
            return .none
        case let .db(.success(.realTimeUpdate(channels, mixtapes))):
            state.channels = channels
            state.mixtapes = mixtapes
            return .none
        case .db(.success(.didFetchAllMixtapes(_))):
            return .none
        case .db(.success(.didFetchAllChannels(_))):
            return .none
        case .settings:
            return .none
        }
    }
}

