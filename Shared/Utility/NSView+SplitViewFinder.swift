//
//  NSView+SplitViewFinder.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/20/22.
//

import Foundation
import AppKit

extension NSView {
    /**
     Finds the first NSSplitView in the view hierarchy, starting with the view this function is called on.
     */
    func findSplitView() -> NSSplitView? {
        var queue = [NSView]()
        queue.append(self)

        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current is NSSplitView {
                return current as? NSSplitView
            }
            for subview in current.subviews {
                queue.append(subview)
            }
        }
        return nil
    }

    /**
     SwiftUI doesn't allow disabling the split view, so we can attempt to find the first NSSplitViewController
     and do it ourselves.

     This is a bit of a hack, but seems like par for the course for SwiftUI.
     */
    func disableSplitViewCollapsingIfPossible() {
        guard let splitView = findSplitView(), let controller = splitView.delegate as? NSSplitViewController else {
            return
        }

        controller.splitViewItems.first?.canCollapse = false
        controller.splitViewItems.first?.minimumThickness = 225
        controller.splitViewItems.first?.maximumThickness = 225
    }
}
