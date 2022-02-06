//
//  MarconioApp.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit
import UserActivityClient

@main
struct MarconioApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(MarconioMacAppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(MarconioiOSAppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
                // This is required to handle the activity registering on iOS, but will *not* be used on macOS for some
                // strange reason.
                .onContinueUserActivity(UserActivityClient.Identifiers.playbackActiveIdentifier.rawValue) { activity in
                    appDelegate.viewStore.send(.appDelegate(.continueActivity(activity)))
                }
        }.commands {
            MarconioCommands()
        }
        // This is required to end up triggering the macOS app delegate, as onContinueUserActivity does
        // not seem to handle macOS for some reason. Not having this will result in new `AppView`'s being
        // created which isn't great.
        .handlesExternalEvents(matching: [UserActivityClient.Identifiers.playbackActiveIdentifier.rawValue])

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
