//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/5/22.
//

import ComposableArchitecture
import Foundation
import Models

/**
 A client that can handle creating and responding to NSUserActivity needs in a structured fashion.

 From within a reducer you can use the various function to return effects and then map them to
 specific handling instructions as follows:

 ```
 ...
 case let .actionToCreateActivityFor(playable):
    return client.becomeCurrent(playable)
 ...
 ```
 */
public struct UserActivityClient {
    /// Identifiers used to set up new `NSUserActivity` types.
    public enum Identifiers: String {
        /// An identifier to be used when handing off playback between iOS and macOS
        case playbackActiveIdentifier = "me.foureyes.marconio.activity.playback"
    }

    /// Keys used for the `userInfo` property on `NSUserAcivity`
    public enum Keys: String {
        case id
        case title
        case subtitle
        case description
        case artwork
        case url
        case streamURL
    }

    /// A function to be called when a given `MediaPlayable` is loaded.
    ///
    /// - Parameters:
    ///     - MediaPlayable: this should be the playable that has been loaded by the playback system.
    public var becomeCurrent: (MediaPlayable) -> Effect<Action, Never>
    /// A function to be called for handling a given activity
    ///
    /// - Parameters:
    ///     - NSUserActivity: an activity that was handed to the application by the system.
    public var handleActivity: (NSUserActivity) -> Effect<Action, Never>

    /// A set of actions that the client can issue.
    public enum Action: Equatable {
        /// Indication that the client will handle the activity in question.
        case willHandleActivity(NSUserActivity)
        /// The client asking the system to make the passed activity the current activity.
        case becomeCurrentActivity(NSUserActivity)
    }
}

public extension NSUserActivity {
    /// A helper for turning an `NSUserActivity` into a `MediaPlayable` or nil if the required keys can't be found.
    func playable() -> MediaPlayable? {
        guard
            let id = userInfo?[UserActivityClient.Keys.id.rawValue] as? String,
            let title = userInfo?[UserActivityClient.Keys.title.rawValue] as? String,
            let description = userInfo?[UserActivityClient.Keys.description.rawValue] as? String,
            let artwork = userInfo?[UserActivityClient.Keys.artwork.rawValue] as? URL,
            let url = userInfo?[UserActivityClient.Keys.url.rawValue] as? URL,
            let streamURL = userInfo?[UserActivityClient.Keys.streamURL.rawValue] as? URL else {
                return nil
            }

        let subtitle = userInfo?[UserActivityClient.Keys.subtitle.rawValue] as? String

        return MediaPlayable(id: id,
                             title: title,
                             subtitle: subtitle,
                             description: description,
                             artwork: artwork,
                             url: url,
                             streamURL: streamURL,
                             source: nil)

    }
}

public extension MediaPlayable {
    /// A helper for turning a `MediaPlayable` into a dictionary to be used by a `NSUserActivity`
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
