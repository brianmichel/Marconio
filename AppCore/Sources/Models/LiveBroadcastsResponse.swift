//
//  Broadcast.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

/**
 A representation of something either currently, or in the future, airing within a ``Channel``.

 Broadcasts are very similar structures to what you might think of as a 'show' within a given channel.
 This representation similarity would be more present if we built in browsing of all of the shows within
 the current NTS catalog. A Broadcast is effectively an episode of a given show in many cases.
 */
public struct Broadcast: Codable, Equatable {
    /**
     Embedded content which describe the specifics of what the containing broadcast is actually playing.

     There are a number of embed types for other API endpoints, however they are unsupported at this time.

     Supported embed types:
     * `details` - Details about the current Broadcast

     Unsupported embed types:
     * `episodes` - The list of episodes associated with a given show (may be paginated)
     */
    public struct Embed: Codable, Equatable {
        /// The status of the embedded media.
        /// Known values:
        /// - `published`
        /// - `pending`
        public let status: String
        /// The date this embedded media was last updated.
        public let updated: Date
        /// The renderable name of the embedded media.
        public let name: String
        /// The description of the embedded media.
        public let description: String
        /// The HTML inclusive description of the embedded media.
        public let descriptionHtml: String
        /// External links provided for the embedded media (i.e. Twitter, Instagram, etc.)
        public let externalLinks: [URL]
        /// An optional shortened version of the location where the media was created.
        public let locationShort: String?
        /// An optional version of the location where the media was created.
        public let locationLong: String?
        /// A set of images to be used when showing information about the embedded media.
        /// This is **not** the streamable media itself.
        public let media: Media
        /// An optional slug for this episodic media.
        public let episodeAlias: String?
        /// An optional slug for the show itself.
        public let showAlias: String
        /// The date of the original broadcast of the media.
        public let broadcast: Date?
        /// An optional URL to a Mixcloud hosted recording.
        let mixcloud: URL?
        // let audioSources []
        // let embeds: {}
        /// A set of API links.
        public let links: [Link]
    }

    /// The user-facing name of the broadcast.
    public let broadcastTitle: String
    /// The start time of this broadcast (in UTC).
    public let startTimestamp: Date
    /// The end time of this broadcast (in UTC).
    public let endTimestamp: Date
    /// A set of API links.
    public let links: [Link]
    /// A set of embedded information related to the broadcast.
    public let embeds: [String: Embed]
}

/**
 An absraction representing a live streaming 'channel' that presents
 a  number of broadcasts.

 While the Channel is effectively just a name an a series of broadcsts
 as defined by it's API, in practice typically onlt the ``now`` and ``next`` values
 have a complete broadcast associated with them.

 As you look into the future of the later broadcasts you will find that
 they do not have a complete set of embed information populated.
 */
public struct Channel: Codable, Equatable {
    /// The name of the channel typically something as simple as "1" or "2"
    public let channelName: String
    /// The broadcast that's currently being streamed.
    public let now: Broadcast
    /// The broadcast that is next up after the broadcast listed at ``now``.
    public let next: Broadcast
}

/// The top level representation of the response from the `/live` API endpoint.
public struct LiveBroadcastsResponse: Codable, Equatable {
    /// The list of channels that are available to stream.
    public let results: [Channel]
    /// A set of API links.
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
