//
//  MarconioApp.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

@main
struct MarconioApp: App {

    #if os(macOS)
    @NSApplicationDelegateAdaptor(MarconioMacAppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(MarconioiOSAppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            AppView(
                store: appDelegate.store
            )
        }.commands {
            MarconioCommands()
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
