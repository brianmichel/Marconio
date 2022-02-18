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

public struct AppState: Equatable {
    public var channels: [Channel] = []
    public var mixtapes: [Mixtape] = []
    public var playback: PlaybackState = .init()
    public var appDelegateState: AppDelegateState
    public var selectedPlayable: MediaPlayable?

    public init(channels: [Channel] = [], mixtapes: [Mixtape] = [], playback: PlaybackState = .init(), appDelegateState: AppDelegateState) {
        self.channels = channels
        self.mixtapes = mixtapes
        self.playback = playback
        self.appDelegateState = appDelegateState
    }

}

public enum AppAction: Equatable {
    case loadInitialData
    case loadChannels
    case channelsResponse(Result<LiveBroadcastsResponse, RunnerError>)
    case loadMixtapes
    case mixtapesResponse(Result<MixtapesResponse, RunnerError>)
    case selectPlayable(MediaPlayable?)
    case playback(PlaybackAction)
    case appDelegate(AppDelegateAction)
    case db(Result<DatabaseClient.Action, DatabaseClient.Error>)
}

public struct AppEnvironment {
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var uuid: () -> UUID
    public var api: NTSAPI
    public var appDelegate: AppDelegateEnvironment
    public var dbClient: DatabaseClient

    public init(mainQueue: AnySchedulerOf<DispatchQueue>, uuid: @escaping () -> UUID, api: NTSAPI, appDelegate: AppDelegateEnvironment, dbClient: DatabaseClient) {
        self.mainQueue = mainQueue
        self.uuid = uuid
        self.api = api
        self.appDelegate = appDelegate
        self.dbClient = dbClient
    }
}

struct AutoUpdatingChannelsId {}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    appDelegateReducer.pullback(
        state: \.appDelegateState,
        action: /AppAction.appDelegate,
        environment: \.appDelegate
    ),
    playbackReducer.pullback(
        state: \.playback,
        action: /AppAction.playback,
        environment: { _ in PlaybackEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .loadInitialData:
            return .merge(
                environment
                    .dbClient
                    .startRealtimeUpdates()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.db),

                .concatenate(
                    try! environment.api.live()
                        .receive(on: environment.mainQueue)
                        .catchToEffect(AppAction.channelsResponse),
                    try! environment.api.mixtapes()
                        .receive(on: environment.mainQueue)
                        .catchToEffect(AppAction.mixtapesResponse)
                )
            )
        case .loadChannels:
            return try! environment.api.live()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.channelsResponse)
        case let .channelsResponse(.success(channels)):
            return .concatenate(
                environment.dbClient.writeChannels(channels.results).catchToEffect(AppAction.db),
                Effect(value: .loadChannels)
                    .deferred(for: .seconds(channels.nextUpdateInterval), scheduler: environment.mainQueue, options: nil)
            )
        case let .channelsResponse(.failure(error)):
            // Do something with the error here
            print("unable to load channels: \(error)")
            return .none
        case .loadMixtapes:
            return try! environment.api.mixtapes()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.mixtapesResponse)
        case let .mixtapesResponse(.success(mixtapes)):
            return .concatenate(
                environment.dbClient.writeMixtapes(mixtapes.results).catchToEffect(AppAction.db)
            )
        case let .mixtapesResponse(.failure(error)):
            // Do something with the error here
            print("unable to load mixtapes: \(error)")
            return .none
        case .playback:
            return .none
        case let .appDelegate(.continueActivity(activity)):
            if let mediaPlayable = activity.playable() {
                return Effect(value: .playback(.loadPlayable(mediaPlayable)))
            }
            return .none
        case .appDelegate:
            return .none
        case let .db(.failure(error)):
            return .none
        case let .db(.success(.realTimeUpdate(channels, mixtapes))):
            state.channels = channels
            state.mixtapes = mixtapes
            return .none
        case .db(.success(.didFetchAllMixtapes(_))):
            return .none
        case .db(.success(.didFetchAllChannels(_))):
            return .none
        case let .selectPlayable(playable):
            state.selectedPlayable = playable
            return .none
        }
    }
)
