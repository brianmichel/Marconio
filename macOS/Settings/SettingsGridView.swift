//
//  GridView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/4/22.
//

import Foundation
import SwiftUI

struct EmptyGridCell: NSViewRepresentable {
    typealias NSViewType = NSView

    func makeNSView(context: Context) -> NSView {
        return NSGridCell.emptyContentView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct SettingsGridView: NSViewRepresentable {
    var views: [[AnyView]]
    var configure: ((NSGridView) -> Void)?

    typealias NSViewType = NSGridView

    func makeNSView(context: Context) -> NSGridView {
        let transformedViews: [[NSView]] = views.map { views in
            return views.map { NSHostingView(rootView: $0) }
        }

        let grid = NSGridView(views: transformedViews)
        grid.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        grid.setContentHuggingPriority(.defaultHigh, for: .vertical)

        grid.column(at: 0).xPlacement = .trailing

        configure?(grid)

        return grid
    }

    func updateNSView(_ nsView: NSGridView, context: Context) {}
}
