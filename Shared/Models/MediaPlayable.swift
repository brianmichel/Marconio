//
//  MediaPlayable.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import LaceKit

struct MediaPlayable: Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String?
    var description: String
    var artwork: URL
    var streamURL: URL
}

extension MediaPlayable {
    init(mixtape: Mixtape) {
        id = mixtape.id
        title = mixtape.title
        subtitle = mixtape.subtitle
        description = mixtape.description
        artwork = mixtape.media.pictureLarge
        streamURL = mixtape.audioStreamEndpoint
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

        streamURL = components.url!
    }
}
