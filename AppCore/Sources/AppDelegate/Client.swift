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

#if os(macOS)
extension SPUStandardUpdaterController: DependencyKey {
    public static var liveValue = SPUStandardUpdaterController(updaterDelegate: nil,
                                                               userDriverDelegate: nil)
}

public extension DependencyValues {
    var sparkleUpdater: SPUStandardUpdaterController {
        get { self[SPUStandardUpdaterController.self] }
        set { self[SPUStandardUpdaterController.self] = newValue }
    }
}
#endif

public struct AppDelegateReducer: ReducerProtocol {
    public enum Action: Equatable {
        case willFinishLaunching
        case didFinishLaunching
        case continueActivity(NSUserActivity)
    }

    #if os(macOS)
    @Dependency(\.sparkleUpdater) var updater
    #endif

    public init() {}

    public struct State: Equatable {
        public var shouldAutoupdate = true
        public var shouldHandleUserActivity = true

        public init(shouldAutoupdate: Bool = true, shouldHandleUserActivity: Bool = true) {
            self.shouldAutoupdate = shouldAutoupdate
            self.shouldHandleUserActivity = shouldHandleUserActivity
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .willFinishLaunching:
#if os(macOS)
                NSWindow.allowsAutomaticWindowTabbing = false
#endif
                return .none
            case .didFinishLaunching:
#if os(macOS)
                if state.shouldAutoupdate {
                    updater.startUpdater()
                }
#endif
                return .none
            case let .continueActivity(activity):
                print("did handle activity \(activity)")
                return .none
            }
        }
    }
}
