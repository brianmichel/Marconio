//
//  MarconioCommands.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import SwiftUI

struct MarconioCommands: Commands {
    var reloadChannels: () -> Void

    var body: some Commands {
        CommandGroup(replacing: .newItem, addition: {})
        CommandGroup(replacing: .undoRedo, addition: {})
        CommandGroup(before: .newItem) {
            Button(action: reloadChannels) {
                Text("Reload channels…")
            }.keyboardShortcut(.init("r", modifiers: .command))
        }
        SidebarCommands()
    }
}
