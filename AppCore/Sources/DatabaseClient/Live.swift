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
    static var live: Self {
        do {
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db", isDirectory: true)

            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let writer = try DatabasePool(path: dbURL.path)

            let allMixtapes = ValueObservation.tracking { db in
                try Mixtape
                    .order(Column("title").asc)
                    .fetchAll(db)
                }
                .publisher(in: writer, scheduling: .immediate)
                .eraseToAnyPublisher()
            let allChannels = ValueObservation.tracking { db in
                try Channel
                    .order(Column("channelName").asc)
                    .fetchAll(db)
                }
                .publisher(in: writer, scheduling: .immediate)
                .eraseToAnyPublisher()

            return Self(
                dbWriter: writer,
                writeChannel: { channel in
                        .run { subscriber in
                            do {
                                try writer.write { db in
                                    try channel.save(db)
                                }
                                subscriber.send(completion: .finished)
                            } catch {
                                subscriber.send(completion: .failure(.unableToWriteData(error.localizedDescription)))
                            }

                            return AnyCancellable {}
                        }
                },
                writeChannels: { channels in
                        .run { subscriber in
                            do {
                                try writer.write { db in
                                    try channels.forEach { channel in
                                        try channel.save(db)
                                    }
                                }
                                subscriber.send(completion: .finished)
                            } catch {
                                subscriber.send(completion: .failure(.unableToWriteData(error.localizedDescription)))
                            }

                            return AnyCancellable {}
                        }
                },
                writeMixtape: { mixtape in
                        .run { subscriber in
                            do {
                                try writer.write { db in
                                    try mixtape.save(db)
                                }
                                subscriber.send(completion: .finished)
                            } catch {
                                subscriber.send(completion: .failure(.unableToWriteData(error.localizedDescription)))
                            }

                            return AnyCancellable {}
                        }
                },
                writeMixtapes: { mixtapes in
                        .run { subscriber in
                            do {
                                try writer.write { db in
                                    try mixtapes.forEach { mixtape in
                                        try mixtape.save(db)
                                    }
                                }
                                subscriber.send(completion: .finished)
                            } catch {
                                subscriber.send(completion: .failure(.unableToWriteData(error.localizedDescription)))
                            }

                            return AnyCancellable {}
                        }
                },
                fetchAllChannels: {
                    .run { subscriber in
                        do {
                            try writer.write { db in
                                let channels = try Channel
                                    .order(Column("channelName").asc)
                                    .fetchAll(db)

                                subscriber.send(.didFetchAllChannels(channels))
                            }
                        } catch {
                            subscriber.send(completion: .failure(.unableToReadData(error.localizedDescription)))
                        }

                        return AnyCancellable {}
                    }
                },
                fetchAllMixtapes: {
                    .run { subscriber in
                        do {
                            try writer.write { db in
                                let mixtapes = try Mixtape
                                    .order(Column("mixtapeAlias").asc)
                                    .fetchAll(db)

                                subscriber.send(.didFetchAllMixtapes(mixtapes))
                            }
                        } catch {
                            subscriber.send(completion: .failure(.unableToReadData(error.localizedDescription)))
                        }

                        return AnyCancellable {}
                    }
                },
                startRealtimeUpdates: {
                    .run { subscriber in
                        return Publishers.Zip(allChannels, allMixtapes).sink(receiveCompletion: { completion in
                            // Do Nothing
                        }) { (channels, mixtapes) in
                            subscriber.send(.realTimeUpdate(channels, mixtapes))
                        }
                    }
                }
            )
        } catch {
            fatalError("Unable to create .live DatabaseClient due to error: \(error)")
        }
    }
}
