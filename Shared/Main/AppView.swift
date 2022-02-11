//
//  AppView.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//

import Combine
import SwiftUI
import ComposableArchitecture
import AVFoundation
import AppCore
import Models
import PlaybackCore
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
            ChannelsView(store: store)
            DonationView()
                .padding()
        }.onAppear {
            viewStore.send(.loadInitialData)
            viewStore.send(.groupActivity(.startSharedListening))
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    channels: [],
                    mixtapes: [],
                    playback: PlaybackState(currentlyPlaying: nil, playerState: .playing),
                    appDelegateState: .init(),
                    groupActivityState: .init()
                ),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: .main,
                    uuid: UUID.init,
                    api: LiveAPI(),
                    appDelegate: .init(),
                    groupActivity: .init(client: .live),
                    dbClient: .live
                )
            )
        )
    }
}
