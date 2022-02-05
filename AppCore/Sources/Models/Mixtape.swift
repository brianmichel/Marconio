//
//  Mixtape.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

public struct Mixtape: Codable, Equatable {
    public var mixtapeAlias: String
    public var title: String
    public var subtitle: String
    public var description: String
    public var descriptionHtml: String
    public var audioStreamEndpoint: URL
    public var media: Media
    public var nowPlayingTopic: String
    public var links: [Link]
}

public struct MixtapesResponse: Codable, Equatable {
    public let results: [Mixtape]
    public let links: [Link]
}

extension Mixtape: Identifiable {
    public var id: String {
        return title
    }
}

extension Mixtape {
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
