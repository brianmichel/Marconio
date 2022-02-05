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
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
