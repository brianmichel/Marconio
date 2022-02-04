//
//  RoutePickerView.swift
//  Marconio
//
//  Created by Brian Michel on 2/3/22.
//

import Foundation
import AVKit
import SwiftUI

#if canImport(AppKit)
struct RoutePickerView: NSViewRepresentable, Equatable {
    var routePickerButtonBordered: Bool = true
    var player: AVPlayer

    typealias NSViewType = AVRoutePickerView

    func makeNSView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.player = player
        view.isRoutePickerButtonBordered = routePickerButtonBordered

        return view
    }

    func updateNSView(_ nsView: AVRoutePickerView, context: Context) {}
}
#endif

#if canImport(UIKit)
struct RoutePickerView: UIViewRepresentable, Equatable {
    var player: AVPlayer
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}

    typealias UIViewType = AVRoutePickerView


}
#endif

