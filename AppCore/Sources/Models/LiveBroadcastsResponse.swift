//
//  Broadcast.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

public struct Broadcast: Codable, Equatable {
    public struct Embed: Codable, Equatable {
        public let status: String
        public let updated: Date
        public let name: String
        public let description: String
        public let descriptionHtml: String
        public let externalLinks: [URL]
        public let locationShort: String?
        public let locationLong: String?
        public let media: Media
        public let episodeAlias: String?
        public let showAlias: String
        public let broadcast: Date?
        let mixcloud: URL?
        // let audioSources []
        // let embeds: {}
        public let links: [Link]
    }

    public let broadcastTitle: String
    public let startTimestamp: Date
    public let endTimestamp: Date
    public let links: [Link]
    public let embeds: [String: Embed]
}

public struct Channel: Codable, Equatable {
    public let channelName: String
    public let now: Broadcast
    public let next: Broadcast
    public let next2: Broadcast
    public let next3: Broadcast
    public let next4: Broadcast
}

public struct LiveBroadcastsResponse: Codable, Equatable {
    public let results: [Channel]
    public let links: [Link]
}

extension Channel: Identifiable {
    public var id: String {
        return channelName
    }
}

extension Broadcast {
    public var details: Embed? {
        return embeds["details"]
    }
}
