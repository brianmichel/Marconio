//
//  MarconioMacAppDelegate.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import AppKit
import Sparkle
import SwiftUI
import ComposableArchitecture
import LaceKit

/// Create an AppDelegate to terminate the application when the last window is closed.
/// This is a hack around SwiftUI for the time being...
final class MarconioMacAppDelegate: NSObject, NSApplicationDelegate {
    let store = Store(
        initialState: AppState(
            channels: [],
            mixtapes: [],
            appDelegateState: .init()
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: .main,
            uuid: UUID.init,
            api: LiveAPI(),
            appDelegate: .init()
        )
    )

    lazy var viewStore = ViewStore(
        self.store.scope(state: { _ in () }),
        removeDuplicates: ==
    )
    private let dockMenu = NSMenu()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        viewStore.send(.appDelegate(.willFinishLaunching))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewStore.send(.appDelegate(.didFinishLaunching))
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }

    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        viewStore.send(.appDelegate(.continueActivity(userActivity)))
        return true
    }
}
