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
    static var live: Self {
        return Self(
            becomeCurrent: { playable in
                Effect.run { subscriber in
                    let activity = NSUserActivity(activityType: Identifiers.playbackActiveIdentifier.rawValue)
                    activity.title = playable.title
                    activity.webpageURL = playable.streamURL
                    activity.isEligibleForHandoff = true

                    activity.userInfo = [
                        Keys.title: playable.title,
                        Keys.description: playable.description,
                        Keys.streamURL: playable.streamURL
                    ]

                    subscriber.send(.becomeCurrentActivity(activity))

                    return AnyCancellable {}
                }
            },
            resignCurrent: {
                Effect.run { subscriber in
                    subscriber.send(.resignCurrentActivity)

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
