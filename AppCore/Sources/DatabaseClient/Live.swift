//
//  File.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import Foundation
import GRDB

public enum DatabaseClientError: Error {
    case unableToCreateContainerURL
}

public extension DatabaseClient {
    static var live: Self {
        do {
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db", isDirectory: true)

            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let dbPool = try DatabasePool(path: dbURL.path)

            let client = try DatabaseClient(dbPool)

            return client
        } catch {
            fatalError("Unable to setup database client due to error: \(error)")
        }
    }
}
