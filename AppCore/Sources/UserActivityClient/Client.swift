//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/5/22.
//

import ComposableArchitecture
import Foundation

struct UserActivityClient {
    var becomeCurrent: () -> Effect<Action, Never>
    var resignCurrent: () -> Effect<Action, Never>
    var handleActivity: (NSUserActivity) -> Effect<Action, Never>

    enum Action: Equatable {
        case willHandleActivity(NSUserActivity)
        case willNotHandleActivity(NSUserActivity)
        case becomeCurrentActivity(NSUserActivity)
        case resignCurrentActivity
    }
}
