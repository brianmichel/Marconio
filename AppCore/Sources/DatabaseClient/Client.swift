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

public struct DatabaseClient {
    let dbWriter: DatabaseWriter

    public var writeChannel: (Channel) -> Effect<Action, DatabaseClient.Error>
    public var writeChannels: ([Channel]) -> Effect<Action, DatabaseClient.Error>
    public var writeMixtape: (Mixtape) -> Effect<Action, DatabaseClient.Error>
    public var writeMixtapes: ([Mixtape]) -> Effect<Action, DatabaseClient.Error>
    public var fetchAllChannels: () -> Effect<Action, DatabaseClient.Error>
    public var fetchAllMixtapes: () -> Effect<Action, DatabaseClient.Error>
    public var startRealtimeUpdates: () -> Effect<Action, DatabaseClient.Error>

    public enum Action: Equatable {
        case didFetchAllMixtapes([Mixtape])
        case didFetchAllChannels([Channel])
        case realTimeUpdate([Channel], [Mixtape])
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

    init(dbWriter: DatabaseWriter, writeChannel: @escaping (Channel) -> Effect<DatabaseClient.Action, DatabaseClient.Error>, writeChannels: @escaping ([Channel]) -> Effect<DatabaseClient.Action, DatabaseClient.Error>, writeMixtape: @escaping (Mixtape) -> Effect<DatabaseClient.Action, DatabaseClient.Error>, writeMixtapes: @escaping ([Mixtape]) -> Effect<DatabaseClient.Action, DatabaseClient.Error>, fetchAllChannels: @escaping () -> Effect<DatabaseClient.Action, DatabaseClient.Error>, fetchAllMixtapes: @escaping () -> Effect<DatabaseClient.Action, DatabaseClient.Error>, startRealtimeUpdates: @escaping () -> Effect<Action, DatabaseClient.Error>) {
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
