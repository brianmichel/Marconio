//
//  AppView.swift
//  Lace
//
//  Created by Brian Michel on 1/29/22.
//

import AppCore
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
        FloatingPlayerOverlayView(store: store) {
            NavigationView {
                SidebarView(store: store).background(
                    // Read the width of the channels view that can be used to inset the
                    // floating mini player by knowning how wide the sidebar is.
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SidebarWidthPreferenceKey.self, value: proxy.size.width)
                    }
                )
                DonationView()
                    .padding()
            }
        }
        .onAppear {
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
                environment: .noop
            )
        )
    }
}
