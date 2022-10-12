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

import Models

public struct AppTileClient {
    public var updateAppTile: (MediaPlayable) -> Void
}

public extension AppTileClient {
    static var live: Self {
        // TODO: This doesn't feel right to pull in the stateful call of the dock menu
        // What's the better way to accomplish this?
        #if os(macOS)
        return Self(
            updateAppTile: { playable in
                let menu = NSApp.delegate?.applicationDockMenu?(NSApp)
                menu?.removeAllItems()
                let heading = NSMenuItem(title: "Now Playing", action: nil, keyEquivalent: "")
                let playable = NSMenuItem(title: "NTS - \(playable.title)", action: nil, keyEquivalent: "")
                menu?.addItem(heading)
                menu?.addItem(playable)
            }
        )
        #else
        return Self(
            updateAppTile: { _ in }
        )
        #endif
    }

    static var noop: Self {
        return .init(updateAppTile: { _ in
                // Do Nothing
        })
    }
}

extension AppTileClient: DependencyKey {
    public static var liveValue: AppTileClient = .live
}

public extension DependencyValues {
    var appTileClient: AppTileClient {
        get { self[AppTileClient.self] }
        set { self[AppTileClient.self] = newValue }
    }
}
