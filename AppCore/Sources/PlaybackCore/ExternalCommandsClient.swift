//
//  ExternalCommandsClient.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Combine
import Foundation
import ComposableArchitecture
import MediaPlayer

public struct ExternalCommandsClient {
    var startMonitoringCommands: () -> EffectPublisher<Action, Never>

    public enum Action: Equatable {
        case externalResumeTap
        case externalPauseTap
        case externalToggleTap
    }
}

public extension ExternalCommandsClient {
    static var live: Self {
        let commandCenter = MPRemoteCommandCenter.shared()

        return Self(
            startMonitoringCommands: {
                Effect.run { subscriber in
                    let play = commandCenter.playCommand.addTarget { event in
                        subscriber.send(.externalResumeTap)
                        return .success
                    }

                    let pause = commandCenter.pauseCommand.addTarget { event in
                        subscriber.send(.externalPauseTap)
                        return .success
                    }

                    let toggle = commandCenter.togglePlayPauseCommand.addTarget { event in
                        subscriber.send(.externalToggleTap)
                        return .success
                    }

                    return AnyCancellable {
                        commandCenter.playCommand.removeTarget(play)
                        commandCenter.pauseCommand.removeTarget(pause)
                        commandCenter.togglePlayPauseCommand.removeTarget(toggle)
                    }
                }
        })
    }

    static var noop: Self {
        return .init(startMonitoringCommands: {
            .none
        })
    }
}

extension ExternalCommandsClient: DependencyKey {
    public static var liveValue: ExternalCommandsClient = .live
}

extension DependencyValues {
    var externalCommandsClient: ExternalCommandsClient {
        get { self[ExternalCommandsClient.self] }
        set { self[ExternalCommandsClient.self] = newValue }
    }
}
