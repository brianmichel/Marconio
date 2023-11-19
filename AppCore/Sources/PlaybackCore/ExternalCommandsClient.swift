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
    var startMonitoringCommands: () async -> AsyncStream<ExternalCommand>

    public enum ExternalCommand: Equatable {
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
                let stream = AsyncStream<ExternalCommand> { continuation in
                    let play = commandCenter.playCommand.addTarget { event in
                        continuation.yield(ExternalCommand.externalResumeTap)
                        return .success
                    }

                    let pause = commandCenter.pauseCommand.addTarget { event in
                        continuation.yield(ExternalCommand.externalPauseTap)
                        return .success
                    }

                    let toggle = commandCenter.togglePlayPauseCommand.addTarget { event in
                        continuation.yield(ExternalCommand.externalToggleTap)
                        return .success
                    }

                    continuation.onTermination = { _ in
                        commandCenter.playCommand.removeTarget(play)
                        commandCenter.pauseCommand.removeTarget(pause)
                        commandCenter.togglePlayPauseCommand.removeTarget(toggle)
                    }
                }

            return stream
        })
    }

    static var noop: Self {
        return .init(startMonitoringCommands: {
            AsyncStream {_ in }
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
