//
//  MarconioCommands.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import Foundation
import SwiftUI

struct MarconioCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem, addition: {})
        CommandGroup(replacing: CommandGroupPlacement.undoRedo, addition: {})
        SidebarCommands()
    }
}
