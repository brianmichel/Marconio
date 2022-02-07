//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import Foundation
import GRDB
import Models

public struct DatabaseClient {
    private let dbWriter: DatabaseWriter

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

    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
}

public extension DatabaseClient {
    func writeChannels(_ channels: [Channel]) throws {
        try dbWriter.write { db in
            try channels.forEach { channel in
                try channel.save(db)
            }
        }
    }

    func writeChannel(_ channel: Channel) throws {
        try dbWriter.write { db in
            try channel.save(db)
        }
    }

    func writeMixtapes(_ mixtapes: [Mixtape]) throws {
        try dbWriter.write { db in
            try mixtapes.forEach { mixtape in
                try mixtape.save(db)
            }
        }
    }

    func writeMixtape(_ mixtape: Mixtape) throws {
        try dbWriter.write { db in
            try mixtape.save(db)
        }
    }
}
