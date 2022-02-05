//
//  Live.swift
//  
//
//  Created by Brian Michel on 2/5/22.
//

import Combine
import Foundation
import ComposableArchitecture

extension String {
    static var playbackActiveIdentifier = "me.foureyes.Marconio.playback"
}

extension UserActivityClient {
    static var live: Self {
        return Self(
            becomeCurrent: {
                Effect.run { subscriber in
                    let activity = NSUserActivity(activityType: .playbackActiveIdentifier)
                    activity.title = "Playing Music"

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
