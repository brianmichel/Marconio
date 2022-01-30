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

struct ExternalCommandsClient {
    var startMonitoringCommands: () -> Effect<Action, Never>

    enum Action: Equatable {
        case externalResumeTap
        case externalPauseTap
    }
}

extension ExternalCommandsClient {
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

                    return AnyCancellable {
                        commandCenter.playCommand.removeTarget(play)
                        commandCenter.pauseCommand.removeTarget(pause)
                    }
                }
        })
    }
}
