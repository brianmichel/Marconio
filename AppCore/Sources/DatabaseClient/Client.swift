//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import ComposableArchitecture
import Foundation
import GRDB
import Models

public struct RealtimeUpdateResult: Equatable {
    public let channels: [Channel]
    public let mixtapes: [Mixtape]
}

public struct DatabaseClient {
    let dbWriter: DatabaseWriter

    public var writeChannel: @Sendable (Channel) async throws -> Void
    public var writeChannels: @Sendable ([Channel]) async throws -> Void
    public var writeMixtape: @Sendable (Mixtape) async throws -> Void
    public var writeMixtapes: @Sendable ([Mixtape]) async throws -> Void
    public var fetchAllChannels: () async throws -> [Channel]
    public var fetchAllMixtapes: () async throws -> [Mixtape]
    public var startRealtimeUpdates: () async -> AsyncStream<RealtimeUpdateResult>

    public enum Action: Equatable {
        case didFetchAllMixtapes(TaskResult<[Mixtape]>)
        case didFetchAllChannels(TaskResult<[Channel]>)
        case realTimeUpdate(TaskResult<RealtimeUpdateResult>)
        case writeFailure(String)
    }

    public enum Error: Swift.Error, Equatable {
        case unableToWriteData(String)
        case unableToReadData(String)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        // Speed things up when working in DEBUG mode
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createChannels") { db in
            try db.create(table: "channel", body: { t in
                t.column("channelName", .text).notNull().primaryKey()
                t.column("now", .blob).notNull()
                t.column("next", .blob).notNull()
            })
        }

        migrator.registerMigration("createMixtapes") { db in
            try db.create(table: "mixtape", body: { t in
                t.column("mixtapeAlias", .text).notNull().primaryKey()
                t.column("title", .text).notNull()
                t.column("subtitle", .text).notNull()
                t.column("description", .text).notNull()
                t.column("descriptionHtml", .text).notNull()
                t.column("audioStreamEndpoint", .text).notNull()
                t.column("media", .blob).notNull()
                t.column("nowPlayingTopic", .text).notNull()
                t.column("links", .blob).notNull()
            })
        }

        return migrator
    }

    internal init(
        dbWriter: DatabaseWriter,
        writeChannel: @escaping @Sendable (Channel) throws -> Void,
        writeChannels: @escaping @Sendable ([Channel]) throws -> Void,
        writeMixtape: @escaping @Sendable (Mixtape) throws -> Void,
        writeMixtapes: @escaping @Sendable ([Mixtape]) throws -> Void,
        fetchAllChannels: @escaping () async throws -> [Channel],
        fetchAllMixtapes: @escaping () async throws -> [Mixtape],
        startRealtimeUpdates: @escaping () async -> AsyncStream<RealtimeUpdateResult>
    ) {
        self.dbWriter = dbWriter
        self.writeChannel = writeChannel
        self.writeChannels = writeChannels
        self.writeMixtape = writeMixtape
        self.writeMixtapes = writeMixtapes
        self.fetchAllChannels = fetchAllChannels
        self.fetchAllMixtapes = fetchAllMixtapes
        self.startRealtimeUpdates = startRealtimeUpdates

        try? migrator.migrate(dbWriter)
    }
}
