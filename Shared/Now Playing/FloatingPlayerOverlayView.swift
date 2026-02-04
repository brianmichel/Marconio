//
//  FloatingPlayerOverlayView.swift
//  Marconio
//
//  Created by Brian Michel on 2/17/22.
//

import SwiftUI
import ComposableArchitecture
import AppCore
import LaceKit

struct FloatingPlayerOverlayView<Content: View>: View {
    @State var sidebarWidth: CGFloat = 0

    let store: StoreOf<AppReducer>
    let content: Content

    init(store: StoreOf<AppReducer>, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer().frame(width: sidebarWidth)
                    nowPlayingView()
                        .shadow(color: .secondary.opacity(0.1), radius: 7, x: 0, y: 0)
                }
            }
        }
        #if os(macOS)
        .onPreferenceChange(SidebarWidthPreferenceKey.self) { preferences in
            self.sidebarWidth = preferences
        }
        #endif
    }

    private func nowPlayingView() -> some View {
        return FloatingPlayerView(
            store: store.scope(
                state: \.playback,
                action: AppReducer.Action.playback
            )
        )
    }
}

struct SidebarWidthPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
    }
}

struct FloatingPlayerOverlayView_Previews: PreviewProvider {
    static let store: StoreOf<AppReducer> = .init(initialState: .init(appDelegate: .init()),
                                                  reducer: { AppReducer(api: NoopAPI()) })
    static var previews: some View {
        FloatingPlayerOverlayView(store: store) {
            VStack {
                Text("Hello World")
                Button("Press me", action: {})
            }
        }
    }
}
