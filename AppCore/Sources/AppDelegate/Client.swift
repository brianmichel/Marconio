//
//  Client.swift
//  Marconio
//
//  Created by Brian Michel on 2/5/22.
//

import Foundation
import ComposableArchitecture
#if os(macOS)
import Sparkle
#endif
import SwiftUI

public enum AppDelegateAction: Equatable {
    case willFinishLaunching
    case didFinishLaunching
    case continueActivity(NSUserActivity)

}

public struct AppDelegateState: Equatable {
    public var shouldAutoupdate = true
    public var shouldHandleUserActivity = true

    public init(shouldAutoupdate: Bool = true, shouldHandleUserActivity: Bool = true) {
        self.shouldAutoupdate = shouldAutoupdate
        self.shouldHandleUserActivity = shouldHandleUserActivity
    }
}

public struct AppDelegateEnvironment: Equatable {
    #if os(macOS)
    public var updater = SPUStandardUpdaterController(updaterDelegate: nil,
                                                           userDriverDelegate: nil)
    #endif

    public init() {}
}

public let appDelegateReducer = Reducer<AppDelegateState, AppDelegateAction, AppDelegateEnvironment>  { state, action, environment in
    switch action {
    case .willFinishLaunching:
        #if os(macOS)
        NSWindow.allowsAutomaticWindowTabbing = false
        #endif
        return .none
    case .didFinishLaunching:
        #if os(macOS)
        if state.shouldAutoupdate {
            environment.updater.startUpdater()
        }
        #endif
        return .none
    case let .continueActivity(activity):
        print("did handle activity \(activity)")
        return .none
    }
}
