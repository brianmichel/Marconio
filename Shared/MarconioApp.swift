//
//  MarconioApp.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

#if os(macOS)
import Preferences
#endif

@main
struct MarconioApp: App {

    #if os(macOS)
    let GeneralPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .general,
            title: "General",
            toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!
        ) {
            GeneralSettingsView()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }
    let AboutPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .about,
            title: "About",
            toolbarIcon: NSImage(systemSymbolName: "books.vertical.fill", accessibilityDescription: "About this app")!
        ) {
            AboutSettingsView()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }

    @NSApplicationDelegateAdaptor(MarconioAppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
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
            )
        }.commands {
            MarconioCommands()
            #if os(macOS)
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences...") {
                    PreferencesWindowController(
                        preferencePanes: [GeneralPreferenceViewController(), AboutPreferenceViewController()],
                        style: .toolbarItems,
                        animated: true,
                        hidesToolbarForSingleItem: true
                    ).show()
                }.keyboardShortcut(KeyEquivalent(","), modifiers: .command)
            }
            #endif
        }
    }
}
