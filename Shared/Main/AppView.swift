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
import AVFoundation
import Models

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
