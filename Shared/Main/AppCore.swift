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
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var api: NTSAPI
    var appDelegate: AppDelegateEnvironment
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
                try! environment.api.live()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.channelsResponse),

                try! environment.api.mixtapes()
                    .receive(on: environment.mainQueue)
                    .catchToEffect(AppAction.mixtapesResponse)
            )
        case .loadChannels:
            return try! environment.api.live()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.channelsResponse)
        case let .channelsResponse(.success(channels)):
            state.channels = channels.results
            return .none
        case let .channelsResponse(.failure(error)):
            // Do something with the error here
            print("unable to load channels: \(error)")
            return .none
        case .loadMixtapes:
            return try! environment.api.mixtapes()
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.mixtapesResponse)
        case let .mixtapesResponse(.success(mixtapes)):
            state.mixtapes = mixtapes.results
            return .none
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
        }
    }
)
