//
//  File.swift
//  
//
//  Created by Brian Michel on 2/8/22.
//

import Foundation
import ComposableArchitecture
import Models
import GRDB

public extension DatabaseClient {
    static var failing: Self {
        let dbQueue = DatabaseQueue()
        return Self(dbWriter: dbQueue,
                    writeChannel: { _ in unimplemented("\(Self.self).writeChannel is unimplemented") },
                    writeChannels: { _ in unimplemented("\(Self.self).writeChannels is unimplemented") },
                    writeMixtape: { _ in unimplemented("\(Self.self).writeMixtape is unimplemented") },
                    writeMixtapes: { _ in unimplemented("\(Self.self).writeMixtapes is unimplemented") },
                    fetchAllChannels: { unimplemented("\(Self.self).fetchAllChannels is unimplemented") },
                    fetchAllMixtapes: { unimplemented("\(Self.self).fetchAllMixtapes is unimplemented") },
                    startRealtimeUpdates: { unimplemented("\(Self.self).startRealtimeUpdates is unimplemented") }
                    )
    }

    static var noop: Self {
        let dbQueue = DatabaseQueue()
        return Self(dbWriter: dbQueue,
                    writeChannel: { _ in },
                    writeChannels: { _ in },
                    writeMixtape: { _ in },
                    writeMixtapes: { _ in },
                    fetchAllChannels: { return [] },
                    fetchAllMixtapes: { return [] },
                    startRealtimeUpdates: { AsyncStream { _ in } }
        )
    }
}

extension DatabaseClient: TestDependencyKey {
    public static var testValue: DatabaseClient = .failing
    public static var previewValue: DatabaseClient = .noop
}
