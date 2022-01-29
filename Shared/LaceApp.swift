//
//  LaceApp.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

@main
struct LaceApp: App {
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
            SidebarCommands()
        }
    }
}
