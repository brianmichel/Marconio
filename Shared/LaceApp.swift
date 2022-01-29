//
//  LaceApp.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI

@main
struct LaceApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }.commands {
            SidebarCommands()
        }
    }
}
