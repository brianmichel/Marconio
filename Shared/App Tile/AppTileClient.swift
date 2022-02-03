//
//  AppTileCore.swift
//  Marconio
//
//  Created by Brian Michel on 2/1/22.
//

import ComposableArchitecture
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

import SwiftUI


struct AppTileClient {
    var updateDockTile: (MediaPlayable) -> Void
}

extension AppTileClient {
    static var live: Self {
        // TODO: This doesn't feel right to pull in the stateful call of the dock menu
        // What's the better way to accomplish this?
        let menu = NSApp.delegate?.applicationDockMenu?(NSApp)

        return Self(
            updateDockTile: { playable in
                menu?.removeAllItems()
                let heading = NSMenuItem(title: "Now Playing", action: nil, keyEquivalent: "")
                let playable = NSMenuItem(title: "NTS - \(playable.title)", action: nil, keyEquivalent: "")
                menu?.addItem(heading)
                menu?.addItem(playable)
            }
        )
    }
}
