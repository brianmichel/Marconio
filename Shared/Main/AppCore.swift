//
//  AppCore.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//
import ComposableArchitecture
import Foundation
import LaceKit
import Models
import DatabaseClient

struct AppState: Equatable {
    var channels: [Channel] = []
    var mixtapes: [Mixtape] = []
    var playback: PlaybackState = PlaybackState()
    var appDelegateState: AppDelegateState
}

enum AppAction: Equatable {
    case loadInitialData
    case loadChannels
    case channelsResponse(Result<LiveBroadcastsResponse, RunnerError>)
    case loadMixtapes
    case mixtapesResponse(Result<MixtapesResponse, RunnerError>)
    case playback(PlaybackAction)
    case appDelegate(AppDelegateAction)
    case dbWrite(Result<DatabaseClient.Action, DatabaseClient.Error>)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var api: NTSAPI
    var appDelegate: AppDelegateEnvironment
    var dbClient: DatabaseClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
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
                    .catchToEffect(AppAction.dbWrite),

                .merge(
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
                environment.dbClient.writeChannels(channels.results).catchToEffect(AppAction.dbWrite)
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
                environment.dbClient.writeMixtapes(mixtapes.results).catchToEffect(AppAction.dbWrite)
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
        case let .dbWrite(.failure(error)):
            return .none
        case let .dbWrite(.success(.realTimeUpdate(channels, mixtapes))):
            state.channels = channels
            state.mixtapes = mixtapes
            return .none
        case .dbWrite(.success(.didFetchAllMixtapes(_))):
            return .none
        case .dbWrite(.success(.didFetchAllChannels(_))):
            return .none
        }
    }
)
