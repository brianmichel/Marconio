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

            struct RealTimeUpdatesId: Hashable {}

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
                                let channels = try Channel.allChannels(db: db)

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
                                let mixtapes = try Mixtape.allMixtapes(db: db)

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
                        let channelsPublisher = ValueObservation.tracking(Channel.allChannels)
                            .publisher(in: writer, scheduling: .immediate)

                        let mixtapesPublisher = ValueObservation.tracking(Mixtape.allMixtapes)
                            .publisher(in: writer, scheduling: .immediate)

                        let latest = Publishers.CombineLatest(channelsPublisher, mixtapesPublisher).sink { failure in
                            print("RealTimeUpdate failure: \(failure)")
                        } receiveValue: { (channels, mixtapes) in
                            subscriber.send(.realTimeUpdate(channels, mixtapes))
                        }

                        return AnyCancellable {
                            _ = (channelsPublisher, mixtapesPublisher, latest)
                        }
                    }.cancellable(id: RealTimeUpdatesId())
                },
                stopRealtimeUpdates: {
                    .cancel(id: RealTimeUpdatesId())
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
