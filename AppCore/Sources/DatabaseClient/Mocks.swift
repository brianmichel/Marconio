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
    #if DEBUG
    static var failing: Self {
        let dbQueue = DatabaseQueue()
        return Self(dbWriter: dbQueue,
                    writeChannel: { _ in .failing("\(Self.self).writeChannel is unimplemented") },
                    writeChannels: { _ in .failing("\(Self.self).writeChannels is unimplemented") },
                    writeMixtape: { _ in .failing("\(Self.self).writeMixtape is unimplemented") },
                    writeMixtapes: { _ in .failing("\(Self.self).writeMixtapes is unimplemented") },
                    fetchAllChannels: { .failing("\(Self.self).fetchAllChannels is unimplemented") },
                    fetchAllMixtapes: { .failing("\(Self.self).fetchAllMixtapes is unimplemented") },
                    startRealtimeUpdates: { .failing("\(Self.self).startRealtimeUpdates is unimplemented") },
                    stopRealtimeUpdates: { .failing("\(Self.self).stopRealtimeUpdates is unimplemented") })
    }
    #endif

    static var noop: Self {
        let dbQueue = DatabaseQueue()
        return Self(dbWriter: dbQueue,
                    writeChannel: { _ in .none },
                    writeChannels: { _ in .none },
                    writeMixtape: { _ in .none },
                    writeMixtapes: { _ in .none },
                    fetchAllChannels: { .none },
                    fetchAllMixtapes: { .none },
                    startRealtimeUpdates: { .none },
                    stopRealtimeUpdates: { .none })
    }
}
