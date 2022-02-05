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
    public var becomeCurrent: (MediaPlayable) -> Effect<Action, Never>
    public var resignCurrent: () -> Effect<Action, Never>
    public var handleActivity: (NSUserActivity) -> Effect<Action, Never>

    public enum Action: Equatable {
        case willHandleActivity(NSUserActivity)
        case willNotHandleActivity(NSUserActivity)
        case becomeCurrentActivity(NSUserActivity)
        case resignCurrentActivity
    }
}
