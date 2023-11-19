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
import AppCore
import AppDelegate
import AppDelegate_macOS

/// Create an AppDelegate to terminate the application when the last window is closed.
/// This is a hack around SwiftUI for the time being...
final class MarconioMacAppDelegate: NSObject, NSApplicationDelegate {
    let store = Store(
        initialState: .init(),
        reducer: { AppReducer(api: LiveAPI()) }
    )

    private let dockMenu = NSMenu()
    private let mainWindow: RadioWindow

    override init() {
        mainWindow = RadioWindow(store: store)
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        store.send(.appDelegate(.willFinishLaunching))
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        store.send(.appDelegate(.didFinishLaunching))

        // HACK: Disable resizing of the split since that's our desired design.
        // NSApp.windows.first?.contentView?.disableSplitViewCollapsingIfPossible()

        // HACK: Disable the zoom button so you can't expand the app to fill the screen.
        // NSApp.windows.first?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false

        mainWindow.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }

    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        store.send(.appDelegate(.continueActivity(userActivity)))
        return true
    }
}
