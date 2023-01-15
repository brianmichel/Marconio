//
//  ShareSheet.swift
//  Marconio (iOS)
//
//  Created by Brian Michel on 2/8/22.
//

#if canImport(UIKit)
import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    public init(items: [Any]) {
        self.items = items
    }

    public typealias UIViewControllerType = UIActivityViewController
    @Environment(\.presentationMode) var presentationMode

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.completionWithItemsHandler = { type, completed, returned, error in
            presentationMode.wrappedValue.dismiss()
        }

        return activity
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
