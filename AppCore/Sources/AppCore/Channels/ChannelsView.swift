//
//  ChannelsView.swift
//  Marconio
//
//  Created by Brian Michel on 1/30/22.
//

import ComposableArchitecture
import LaceKit
import Models
import PlaybackCore
import SwiftUI

extension AppState {
    var sidebarState: SidebarState {
        return .init(channels: channels, mixtapes: mixtapes, playback: playback)
    }
}

struct SidebarState: Equatable {
    var channels: [Channel]
    var mixtapes: [Mixtape]
    var playback: PlaybackState
}

public struct ChannelsView: View {
    let store: Store<AppState, AppAction>

    private let viewStore: ViewStore<SidebarState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: { $0.sidebarState }))
    }

    public var body: some View {
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
                        ChannelRow(channel: channel)
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
        .refreshable {
            viewStore.send(.loadChannels)
        }
        #if os(macOS)
        .toolbar {
            // HACK: Without this the toolbar will switch between two different types which is very ugly.
            Spacer()
        }
        #endif
        .frame(maxHeight: .infinity)
        .listStyle(.sidebar)
        .navigationTitle("Channels")
    }

    var isPlayingBack: Bool {
        return viewStore.playback.playerState != .stopped
    }

    private func destination(for playable: MediaPlayable) -> some View {
        let scopedStore = store.scope(state: \.playback, action: AppAction.playback)

        return ScrollView {
            VStack {
                DetailView(playable: playable, store: scopedStore)
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
                environment: .stub
            )
        )
    }
}
