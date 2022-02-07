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
import AppKit

public struct RoutePickerView: NSViewRepresentable, Equatable {
    public var routePickerButtonBordered: Bool = true
    public var player: AVPlayer

    public typealias NSViewType = AVRoutePickerView

    public init(routePickerButtonBordered: Bool = true, player: AVPlayer) {
        self.routePickerButtonBordered = routePickerButtonBordered
        self.player = player
    }

    public func makeNSView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.player = player
        view.isRoutePickerButtonBordered = routePickerButtonBordered

        return view
    }

    public func updateNSView(_ nsView: AVRoutePickerView, context: Context) {}
}
#endif

#if canImport(UIKit)
import UIKit

public struct RoutePickerView: UIViewRepresentable, Equatable {
    public var player: AVPlayer
    public func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        return view
    }

    public init(player: AVPlayer) {
        self.player = player
    }

    public func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}

    public typealias UIViewType = AVRoutePickerView
}
#endif

