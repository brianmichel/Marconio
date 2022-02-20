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
    private let store: Store<PlaybackState, PlaybackAction>
    @ObservedObject private var viewStore: ViewStore<PlaybackState, PlaybackAction>

    @State var expanded = false
    @State var showing = false

    var canExpand: Bool {
        return viewStore.currentlyPlaying != nil
    }

    init(store: Store<PlaybackState, PlaybackAction>, expanded: Bool = false) {
        self.store = store
        self.expanded = expanded
        viewStore = ViewStore(store)
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

struct NowPlayingDetailView: View {
    private let store: Store<PlaybackState, PlaybackAction>
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    init(store: Store<PlaybackState, PlaybackAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var title: String {
        guard let playable = viewStore.currentlyPlaying else {
            return "Unknown Sounds"
        }

        switch playable.source {
        case .left(_):
            return "live"
        case .right(_):
            return "infinite mixtape"
        case .none:
            return "Unknown Sounds"
        }
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title.uppercased()).font(.system(.subheadline, design: .rounded)).foregroundColor(.secondary)
                        Spacer().frame(height: 7)
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle").font(.system(size: 18))
                        }
                        .buttonStyle(.borderless)
                    }
                    Spacer().frame(height: 10)
                    Text(viewStore.currentlyPlaying?.description ?? "Description")
                }
            }
            Divider()
        }
    }
}

struct FloatingPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloatingPlayerView(store: Store(
                initialState: PlaybackState(),
                reducer: playbackReducer,
                environment: PlaybackEnvironment()
            ))

            FloatingPlayerView(store: Store(
                initialState: PlaybackState(currentlyPlaying: MediaPlayable(mixtape: .placeholder), playerState: .playing, currentActivity: nil, routePickerView: nil, monitoringRemoteCommands: false),
                reducer: playbackReducer,
                environment: PlaybackEnvironment()
            ),
                               expanded: true).preferredColorScheme(.light)
        }
    }
}
