//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/5/22.
//

import ComposableArchitecture
import Foundation
import Models

public struct UserActivityClient {
    public enum Identifiers: String {
        case playbackActiveIdentifier = "me.foureyes.marconio.activity.playback"
    }

    public enum Keys: String {
        case id
        case title
        case subtitle
        case description
        case artwork
        case streamURL
    }

    public var becomeCurrent: (MediaPlayable) -> Effect<Action, Never>
    public var resignCurrent: () -> Effect<Action, Never>
    public var handleActivity: (NSUserActivity) -> Effect<Action, Never>

    public enum Action: Equatable {
        case willHandleActivity(NSUserActivity)
        case becomeCurrentActivity(NSUserActivity)
        case resignCurrentActivity
    }
}

public extension NSUserActivity {
    func playable() -> MediaPlayable? {
        guard
            let id = userInfo?[UserActivityClient.Keys.id.rawValue] as? String,
            let title = userInfo?[UserActivityClient.Keys.title.rawValue] as? String,
            let description = userInfo?[UserActivityClient.Keys.description.rawValue] as? String,
            let artwork = userInfo?[UserActivityClient.Keys.artwork.rawValue] as? URL,
            let streamURL = userInfo?[UserActivityClient.Keys.streamURL.rawValue] as? URL else {
                return nil
            }

        let subtitle = userInfo?[UserActivityClient.Keys.subtitle.rawValue] as? String

        return MediaPlayable(id: id,
                             title: title,
                             subtitle: subtitle,
                             description: description,
                             artwork: artwork,
                             streamURL: streamURL)

    }
}

public extension MediaPlayable {
    func handoffUserInfo() -> [AnyHashable: Any] {
        var userInfo: [AnyHashable: Any] = [
            UserActivityClient.Keys.id.rawValue: id,
            UserActivityClient.Keys.title.rawValue: title,
            UserActivityClient.Keys.description.rawValue: description,
            UserActivityClient.Keys.artwork.rawValue: artwork,
            UserActivityClient.Keys.streamURL.rawValue: streamURL
        ]

        if let sub = subtitle {
            userInfo[UserActivityClient.Keys.subtitle.rawValue] = sub
        }

        return userInfo
    }
}
