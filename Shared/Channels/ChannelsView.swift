//
//  ChannelsView.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit
import Models

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
                        let playable = MediaPlayable(channel: channel)
                        NavigationLink(destination: destination(for: playable)
                        ) {
                            Label("Channel \(channel.channelName)", systemImage: "radio")
                        }
                        .contextMenu {
                            contextButton(for: playable)
                        }
                    }
                }

                Section("Infinite Mixtapes") {
                    ForEach(viewStore.mixtapes) { mixtape in
                        let playable = MediaPlayable(mixtape: mixtape)
                        NavigationLink(destination: destination(for: playable)) {
                            Label("\(mixtape.title)", systemImage: mixtape.systemIcon)
                        }
                        .contextMenu {
                            contextButton(for: playable)
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

    private func contextButton(for playable: MediaPlayable) -> some View {
        let isPlayingPlayable = viewStore.playback.currentlyPlaying == playable
        let iconName = isPlayingPlayable ? "pause.fill" : "play.fill"
        let action = isPlayingPlayable ? PlaybackAction.pausePlayback : PlaybackAction.loadPlayable(playable)
        let buttonTitle = isPlayingPlayable ? "Pause" : "Play"

        return Button {
            viewStore.send(AppAction.playback(action))
        } label: {
            Label(buttonTitle, systemImage: iconName)
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
                    playback: PlaybackState(currentlyPlaying: nil, playerState: .playing),
                    appDelegateState: .init()
                ),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: .main,
                    uuid: UUID.init,
                    api: LiveAPI(),
                    appDelegate: .init()
                )
            )
        )
    }
}
