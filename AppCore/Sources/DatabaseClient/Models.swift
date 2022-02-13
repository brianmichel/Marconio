//
//  File.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import Foundation
import Models
import GRDB

extension Mixtape: PersistableRecord, FetchableRecord {
    static func allMixtapes(db: Database) throws -> [Mixtape] {
        return try Mixtape
            .order(Column("title").asc)
            .fetchAll(db)
    }
}
extension Channel: PersistableRecord, FetchableRecord {
    static func allChannels(db: Database) throws -> [Channel] {
        return try Channel
            .order(Column("channelName").asc)
            .fetchAll(db)
    }
}
