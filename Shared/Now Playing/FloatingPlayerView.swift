//
//  FloatingPlayerView.swift
//  Marconio
//
//  Created by Brian Michel on 2/13/22.
//

import SwiftUI
import ComposableArchitecture
import PlaybackCore
import Models

struct FloatingPlayerView: View {
    private let store: StoreOf<PlaybackReducer>
    @ObservedObject private var viewStore: ViewStoreOf<PlaybackReducer>

    @State var expanded = false
    @State var showing = false

    var canExpand: Bool {
        return viewStore.currentlyPlaying != nil
    }

    init(store: StoreOf<PlaybackReducer>, expanded: Bool = false) {
        self.store = store
        self.expanded = expanded
        viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            Spacer()
            VStack {
                if expanded {
                    NowPlayingDetailView(store: store)
                        .opacity(expanded ? 1.0 : 0.0)
                        .scaleEffect(expanded ? 1.0 : 0.3)
                        .padding([.horizontal, .top])
                }
                NowPlayingView(store: store).padding(.horizontal)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
            .padding()
            .onTapGesture {
                if canExpand {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.6)) {
                        expanded.toggle()
                    }
                }
            }
            .offset(x: 0, y: showing ? 0 : 500 )
        }.onChange(of: canExpand) { newValue in
            withAnimation(.linear(duration: 0.3)) {
                showing = newValue
            }
        }
    }
}

struct FloatingPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloatingPlayerView(store: Store(
                initialState: .init(),
                reducer: { PlaybackReducer() }
            ))

            FloatingPlayerView(store: Store(
                initialState: .init(currentlyPlaying: MediaPlayable(mixtape: .placeholder),
                                    playerState: .playing,
                                    currentActivity: nil,
                                    routePickerView: nil,
                                    monitoringRemoteCommands: false),
                reducer: { PlaybackReducer() }
            ),
                               expanded: true).preferredColorScheme(.light)
        }
    }
}
