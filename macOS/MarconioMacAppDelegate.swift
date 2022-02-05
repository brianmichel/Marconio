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
            mixtapes: []
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: .main,
            uuid: UUID.init,
            api: LiveAPI()
        )
    )

    lazy var viewStore = ViewStore(
        self.store.scope(state: { _ in () }),
        removeDuplicates: ==
    )
    private let dockMenu = NSMenu()
    @AppStorage("ShouldAutoupdate") private var shouldAutoupdate = true

    private let updater = SPUStandardUpdaterController(updaterDelegate: nil,
                                                       userDriverDelegate: nil)
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if shouldAutoupdate {
            updater.startUpdater()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
}
