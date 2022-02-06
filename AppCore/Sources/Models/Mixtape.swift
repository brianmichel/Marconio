//
//  Mixtape.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

/// An infinite mixtape that has been curated by the folks at https://nts.live. It will play forever (I think).
public struct Mixtape: Codable, Equatable {
    /// The slug for a given mixtape.
    public var mixtapeAlias: String
    /// The renderable name of a given mixtape.
    public var title: String
    /// The short tet describing a mixtape.
    public var subtitle: String
    /// The longer text describing the content of a mixtape.
    public var description: String
    /// The longer text describing the content of a mixtape, annotated in HTML.
    public var descriptionHtml: String
    /// The URL of where to stream the mixtape.
    public var audioStreamEndpoint: URL
    /// A set of images to be used when showing information about the embedded media.
    /// This is **not** the streamable media itself.
    public var media: Media
    /// No idea what this is actually for!
    public var nowPlayingTopic: String
    /// A set of API links.
    public var links: [Link]
}

/// The top level representation of the response from the `/mixtapes` API endpoint.
public struct MixtapesResponse: Codable, Equatable {
    /// The list of mixtapes that are available to stream.
    public let results: [Mixtape]
    /// A set of API links.
    public let links: [Link]
}

extension Mixtape: Identifiable {
    public var id: String {
        return title
    }
}

extension Mixtape {
    /// A sample Mixtape to be used in mocks and previews.
   public static var placeholder: Self {
        return Mixtape(mixtapeAlias: "place-holder",
                       title: "Placeholder",
                       subtitle: "The best placeholder station on the 'net",
                       description: "A longer, but easy to understand description. It should be long enough to wrap around in the viewport to see how it looks.",
                       descriptionHtml: "<h3>A longer, but <b>easy</b> to understand description</h3>. It should be long enough to wrap around in the viewport to see how it looks.",
                       audioStreamEndpoint: URL(string: "https://www.nts.live")!,
                       media: .placeholder,
                       nowPlayingTopic: "now-playing",
                       links: [])
    }
}
