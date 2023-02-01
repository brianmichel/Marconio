//
//  CDChildWindow.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 1/31/23.
//

import AppCore
import AppKit
import ComposableArchitecture
import Inject
import PlaybackCore
import SwiftUI

final class CDChildWindow: NSWindow {
    private let store: Store<PlaybackReducer.State, AppReducer.Action>
    private let cdChildView: CDChildContentView

    init(parent: NSRect, store: Store<PlaybackReducer.State, AppReducer.Action>) {
        let x = parent.maxX - 120 / 2
        let y = parent.maxY - 120 - 32
        self.store = store
        self.cdChildView = CDChildContentView(store: store)

        super.init(
            contentRect: NSRect(x: x, y: y, width: 120, height: 120),
            styleMask: [.fullSizeContentView],
            backing: .buffered, defer: false)


        isOpaque = false
        backgroundColor = .clear

        contentView = NSHostingView(rootView: cdChildView)
    }

    func showCD() {
        cdChildView.showCD()
    }

    func hideCD() {
        cdChildView.hideCD()
    }
}

struct CDChildContentView: View {
    @ObserveInjection var inject

    @State private var rotating = false
    @State private var degrees = 0.0
    @State private var cdHidden = true

    let store: Store<PlaybackReducer.State, AppReducer.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                background()
                if let playing = viewStore.currentlyPlaying {
                    AsyncImage(url: playing.artwork) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        EmptyView()
                    }
                    .opacity(0.8)
                    .mask(background())
                }
            }
            .padding(3)
            .offset(x: cdHidden ? -60.0 : 0.0)
            .rotationEffect(.degrees(degrees))
            .onAppear {
                showCD()
                startAnimation()
            }
            .onDisappear {
                rotating = false
            }
        }
        .enableInjection()
    }

    func showCD() {
        withAnimation(.easeIn(duration: 0.3)) {
            cdHidden = false
        }
    }

    func hideCD() {
        stopAnimation()
        withAnimation(.easeIn(duration: 0.3)) {
            cdHidden = true
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 2.7).repeatForever(autoreverses: false)) {
            rotating = true
            degrees += 1080
        }
    }

    private func stopAnimation() {
        withAnimation(.linear(duration: 1.0)) {
            rotating = false
            degrees = 0
        }
    }

    private func background() -> some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
            Circle()
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 40, height: 40)
                .blendMode(.destinationOut)
            Circle()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
}
