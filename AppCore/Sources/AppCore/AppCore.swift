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
        case db(DatabaseClient.Action)
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
                .run(operation: { send in
                    for await result in await dbClient.startRealtimeUpdates() {
                        await send(.db(.realTimeUpdate(.success(result))))
                    }
                })
                .cancellable(id: DatabaseClient.RealTimeUpdatesId()),
                .concatenate(
                    .run(operation: { send in
                        let response = try await api.live()
                        await send(.channelsResponse(.success(response)))
                    }, catch: { error, send in
                        guard let runnerError = error as? RunnerError else { return }
                        await send(.channelsResponse(.failure(runnerError)))
                    }),
                    .run(operation: { send in
                        let response = try await api.mixtapes()
                        await send(.mixtapesResponse(.success(response)))
                    }, catch: { error, send in
                        guard let runnerError = error as? RunnerError else { return }
                        await send(.mixtapesResponse(.failure(runnerError)))
                    })
                )
            )
        case .loadChannels:
            return .run(operation: { send in
                let response = try await api.live()
                await send(.channelsResponse(.success(response)))
            }, catch: { error, send in
                guard let runnerError = error as? RunnerError else { return }
                await send(.channelsResponse(.failure(runnerError)))
            })
        case let .channelsResponse(.success(channels)):
            return .concatenate(
                .run(operation: { send in
                    try await dbClient.writeChannels(channels.results)
                }, catch: { error, send in
                    await send(.db(.writeFailure(error.localizedDescription)))
                }),
                .run(operation: { send in
                    try await mainQueue.sleep(for: .seconds(channels.nextUpdateInterval))
                    await send(.loadChannels)
                })

            )
        case let .channelsResponse(.failure(error)):
            // Do something with the error here
            print("unable to load channels: \(error)")
            return .none
        case .loadMixtapes:
            return .run(operation: { send in
                let response = try await api.mixtapes()
                await send(.mixtapesResponse(.success(response)))
            }, catch: { error, send in
                guard let runnerError = error as? RunnerError else { return }
                await send(.mixtapesResponse(.failure(runnerError)))
            })
        case let .mixtapesResponse(.success(mixtapes)):
            return .concatenate(
                .run(operation: { send in
                    try await dbClient.writeMixtapes(mixtapes.results)
                }, catch: { error, send in
                    await send(.db(.writeFailure(error.localizedDescription)))
                })
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
        case let .db(.realTimeUpdate(.success(result))):
            state.channels = result.channels
            state.mixtapes = result.mixtapes
            return .none
        case .db(_):
            return .none
        case .settings:
            return .none
        }
    }
}

