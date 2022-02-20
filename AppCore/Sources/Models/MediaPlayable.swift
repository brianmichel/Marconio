//
//  MediaPlayable.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation

/**
 A common abstraction to represent anything that can be playable within the application.

 You can create a ``MediaPlayable`` from a ``Mixtape`` or a ``Channel`` using the initializers below,
 or you can populate your own using the public initializer that's been provided for mocking and
 other needs.

 ```
 // From a channel
 let channel = ...
 let playable = MediaPlayble(channel: channel)

 // From a mixtape
 let mixtape = ...
 let playable = MediaPlayable(mixtape: mixtape)
 ```
 */
public struct MediaPlayable: Identifiable, Equatable {
    public var id: String
    public var title: String
    public var subtitle: String?
    public var description: String
    public var artwork: URL
    public var url: URL
    public var streamURL: URL
    public var source: Either<Channel, Mixtape>?

    public init(id: String, title: String, subtitle: String? = nil, description: String, artwork: URL, url: URL, streamURL: URL, source: Either<Channel, Mixtape>?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.artwork = artwork
        self.url = url
        self.streamURL = streamURL
        self.source = source
    }
}

public extension MediaPlayable {
    init(mixtape: Mixtape) {
        id = mixtape.id
        title = mixtape.title
        subtitle = mixtape.subtitle
        description = mixtape.description
        artwork = mixtape.media.pictureLarge
        url = mixtape.url ?? URL(string: "https://nts.live")!
        streamURL = mixtape.audioStreamEndpoint
        source = .right(mixtape)
    }

    init(channel: Channel) {
        id = channel.id
        title = "Channel \(channel.channelName)"
        description = "Description not provided by NTS or broadcaster."

        if let programDescription = channel.now.details?.description, !programDescription.isEmpty {
            description = programDescription
        }

        subtitle = channel.now.broadcastTitle

        artwork = channel.now.details?.media.backgroundLarge ?? URL(fileURLWithPath: "file://")

        var components = URLComponents()
        components.scheme = "https"
        components.host = "stream-relay-geo.ntslive.net"

        switch channel.channelName {
        case "1":
            components.path = "/stream"
        case "2":
            components.path = "/stream2"
        default:
            print("Unknown stream channel has been provided, returning a stream URL that will not stream")
        }

        url = channel.now.details?.url ?? URL(string: "https://nts.live")!
        streamURL = components.url!

        source = .left(channel)
    }
}
