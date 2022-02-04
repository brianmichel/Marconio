//
//  MarconioAppDelegate.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import AppKit
import Sparkle

/// Create an AppDelegate to terminate the application when the last window is closed.
/// This is a hack around SwiftUI for the time being...
class MarconioAppDelegate: NSObject, NSApplicationDelegate {
    private let dockMenu = NSMenu()
    private let updater = SPUStandardUpdaterController(startingUpdater: true,
                                                       updaterDelegate: nil,
                                                       userDriverDelegate: nil)
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
}
