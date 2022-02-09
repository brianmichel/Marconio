//
//  ShareSheet.swift
//  Marconio (iOS)
//
//  Created by Brian Michel on 2/8/22.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    typealias UIViewControllerType = UIActivityViewController
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.completionWithItemsHandler = { type, completed, returned, error in
            presentationMode.wrappedValue.dismiss()
        }

        return activity
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}


}
