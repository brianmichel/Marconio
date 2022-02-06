//
//  Live.swift
//  
//
//  Created by Brian Michel on 2/5/22.
//

import Combine
import Foundation
import ComposableArchitecture
import Models

public extension UserActivityClient {
    /// A live implementation of the `UserActivityClient` which can be used to create and handle activity items.
    static var live: Self {
        return Self(
            becomeCurrent: { playable in
                Effect.run { subscriber in
                    let activity = NSUserActivity(activityType: Identifiers.playbackActiveIdentifier.rawValue)
                    activity.title = playable.title
                    activity.webpageURL = playable.streamURL
                    activity.isEligibleForHandoff = true

                    activity.userInfo = playable.handoffUserInfo()

                    subscriber.send(.becomeCurrentActivity(activity))

                    return AnyCancellable {}
                }
            },
            handleActivity: { activity in
                Effect.run { subscriber in
                    subscriber.send(.willHandleActivity(activity))

                    return AnyCancellable {}
                }
            }
        )
    }
}
