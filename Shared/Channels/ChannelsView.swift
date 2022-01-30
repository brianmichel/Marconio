//
//  ChannelsView.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

struct ChannelsView: View {
    let store: Store<AppState, AppAction>

    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }

    struct ViewState: Equatable {
        var channels: [Channel]
        var mixtapes: [Mixtape]
        var playback: PlaybackState

        init(state: AppState) {
            channels = state.channels
            mixtapes = state.mixtapes
            playback = state.playback
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
#if os(iOS)
                // We have to remove the inset set by the List's stlye
                // otherwise we will have more padding on the left than the right.
                DonationView()
                    .listRowInsets(EdgeInsets())
                    .padding()
#endif
                Section("Live") {
                    ForEach(viewStore.channels) { channel in
                        NavigationLink(destination: destination(for: MediaPlayable(channel: channel))
                        ) {
                            Label("Channel \(channel.channelName)", systemImage: "radio")
                        }
                    }
                }

                Section("Infinite Mixtapes") {
                    ForEach(viewStore.mixtapes) { mixtape in
                        NavigationLink(destination: destination(for: MediaPlayable(mixtape: mixtape))) {
                            Label("\(mixtape.title)", systemImage: mixtape.systemIcon)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .listStyle(.sidebar)
            .navigationTitle("Channels")
#if os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar, label: {
                        Label("Sidebar", systemImage: "sidebar.leading")
                    })
                }
            }
#endif
            if isPlayingBack {
                nowPlayingView()
            }
        }
    }

    private func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }

    var isPlayingBack: Bool {
        return viewStore.playback.playerState != .stopped
    }

    private func footerView() -> some View {
        let height: Double = isPlayingBack ? 60 : 0
        return Text("").frame(height: height)
    }

    private func nowPlayingView() -> some View {
        return NowPlayingView(
            store: store.scope(
                state: \.playback,
                action: AppAction.playback
            )
        )
    }

    private func destination(for playable: MediaPlayable) -> some View {
        return ScrollView {
            VStack {
                DetailView(playable: playable, store: store.scope(state: \.playback, action: AppAction.playback))
                    .padding()
                Spacer()
            }
        }
    }
}

struct ChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsView(
            store: Store(
                initialState: AppState(
                    channels: [],
                    mixtapes: [],
                    playback: PlaybackState(currentlyPlaying: nil, playerState: .playing)
                ),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: .main,
                    uuid: UUID.init,
                    api: LiveAPI()
                )
            )
        )
    }
}
