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
import Inject
import Utilities
import Dependencies
import HapticsClient


struct AppView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>

    @ObserveInjection var inject

    @Dependency(\.hapticsClient) var hapticsClient

    init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: { .init(state: $0) })
    }

    struct ViewState: Equatable {
        var channels: [Channel]
        var mixtapes: [Mixtape]
        var playback: PlaybackReducer.State
        var settings: SettingsReducer.State

        init(state: AppReducer.State) {
            channels = state.channels
            mixtapes = state.mixtapes
            playback = state.playback
            settings = state.settings
        }
    }

    var body: some View {
        core
        .onAppear {
            viewStore.send(.loadInitialData)
        }
        .enableInjection()
    }

    @ViewBuilder
    var core: some View {
        ZStack {
            Rectangle().foregroundColor(Color(rgb: 0x262626))
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("logo")
                        .foregroundColor(Color(rgb: 0xCECECE))
                        .accessibilityLabel("Marconio")
                        .shadow(color: .white.opacity(0.3), radius: 0.4, x: 0, y: 0.3)
                }
                .frame(height: 20)
                .padding(.top, 5)
                .padding(.horizontal, 8)
                LCDPanelView(store: store)
                    .frame(height: 100)
                StationSelectorView(
                    mixtapes: viewStore.mixtapes,
                    accentColor: Color(rgb: viewStore.settings.accentColor.rawValue),
                    currentlyPlaying: viewStore.playback.currentlyPlaying,
                    onPlay: { playable in
                        // Resolve channel sentinel IDs to real channel data
                        if playable.id == "channel-1", viewStore.channels.count > 0 {
                            viewStore.send(.playback(.loadPlayable(MediaPlayable(channel: viewStore.channels[0]))))
                        } else if playable.id == "channel-2", viewStore.channels.count > 1 {
                            viewStore.send(.playback(.loadPlayable(MediaPlayable(channel: viewStore.channels[1]))))
                        } else {
                            viewStore.send(.playback(.loadPlayable(playable)))
                        }
                    }
                )
                .padding(.top, 5)
                .padding(.bottom, 5)
                horizontalDivider
                Spacer()
            }
        }
        .enableInjection()
        .ignoresSafeArea()
    }

    @ViewBuilder
    var horizontalDivider: some View {
        VStack(spacing: 0) {
            Rectangle().frame(height: 0.5)
                .foregroundColor(.black)
            Rectangle().frame(height: 0.5)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 1)
        .opacity(0.3)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: .init(
                    channels: [Channel](),
                    mixtapes: [Mixtape](),
                    playback: .init(currentlyPlaying: nil, playerState: .playing),
                    appDelegate: .init()
                ),
                reducer: { AppReducer(api: NoopAPI()) }
            )
        )
        .frame(width: 320)
    }
}
