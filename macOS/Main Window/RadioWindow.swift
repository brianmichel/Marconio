//
//  RadioWindow.swift
//  Marconio
//
//  Created by Brian Michel on 1/24/23.
//

import AppCore
import AppKit
import ComposableArchitecture
import SwiftUI

final class RadioWindow: NSWindow {
    private let store: StoreOf<AppReducer>

    init(store: StoreOf<AppReducer>) {
        self.store = store

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 500),
            styleMask: [.closable, .miniaturizable, .titled, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false)

        setFrameAutosaveName("RadioWindow")
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        title = "Marconio"

        contentView = NSHostingView(rootView: AppView(store: store))
    }
}
