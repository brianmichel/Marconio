//
//  File.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import Foundation
import Combine
import ComposableArchitecture
import GRDB
import Models

public extension DatabaseClient {
    struct RealTimeUpdatesId: Hashable {
        public init() {}
    }

    static var live: Self {
        do {
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db", isDirectory: true)

            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let writer = try DatabasePool(path: dbURL.path)

            return Self(
                dbWriter: writer,
                writeChannel: { channel in
                    do {
                        try writer.write { db in
                            try channel.save(db)
                        }
                    } catch {
                        throw DatabaseClient.Error.unableToWriteData(error.localizedDescription)
                    }
                },
                writeChannels: { channels in
                    do {
                        try writer.write { db in
                            try channels.forEach { channel in
                                try channel.save(db)
                            }
                        }
                    } catch {
                        throw DatabaseClient.Error.unableToWriteData(error.localizedDescription)
                    }
                },
                writeMixtape: { mixtape in
                    do {
                        try writer.write { db in
                            try mixtape.save(db)
                        }
                    } catch {
                        throw DatabaseClient.Error.unableToWriteData(error.localizedDescription)
                    }
                },
                writeMixtapes: { mixtapes in
                    do {
                        try writer.write { db in
                            try mixtapes.forEach { mixtape in
                                try mixtape.save(db)
                            }
                        }
                    } catch {
                    }
                },
                fetchAllChannels: {
                    do {
                        let channels = try writer.write { db in
                            try Channel.allChannels(db: db)
                        }
                        return channels
                    } catch {
                        throw DatabaseClient.Error.unableToReadData(error.localizedDescription)
                    }
                },
                fetchAllMixtapes: {
                    do {
                        let mixtapes = try writer.write { db in
                            try Mixtape.allMixtapes(db: db)
                        }
                        return mixtapes
                    } catch {
                        throw DatabaseClient.Error.unableToReadData(error.localizedDescription)
                    }
                },
                startRealtimeUpdates: {
                    AsyncStream { continuation in
                        Task { @MainActor in
                            let channelsPublisher = ValueObservation.tracking(Channel.allChannels)
                                .publisher(in: writer, scheduling: .immediate)

                            let mixtapesPublisher = ValueObservation.tracking(Mixtape.allMixtapes)
                                .publisher(in: writer, scheduling: .immediate)

                            let latest = Publishers
                                .CombineLatest(channelsPublisher, mixtapesPublisher)
                                .sink { failure in
                                print("RealTimeUpdate failure: \(failure)")
                            } receiveValue: { (channels, mixtapes) in
                                let result = RealtimeUpdateResult(channels: channels, mixtapes: mixtapes)
                                continuation.yield(result)
                            }

                            return latest
                        }
                    }
                }
            )
        } catch {
            fatalError("Unable to create .live DatabaseClient due to error: \(error)")
        }
    }
}

extension DatabaseClient: DependencyKey {
    public static var liveValue: DatabaseClient = .live
}
