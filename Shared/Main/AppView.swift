//
//  AppView.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//

import Combine
import SwiftUI
import ComposableArchitecture
import LaceKit

struct AppView: View {
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
        NavigationView {
            List {
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
            .listStyle(.sidebar)
            .navigationTitle("Channels")
        #if os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: refresh, label: {
                        Image(systemName: "arrow.clockwise")
                    }).keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
                }
            }
        #endif
            DonationView().padding()
        }.onAppear {
            viewStore.send(.loadInitialData)
        }
    }

    private func refresh() {
        self.viewStore.send(.loadInitialData)
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

    private func toggleSidebar() { // 2
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    channels: [],
                    mixtapes: []
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
