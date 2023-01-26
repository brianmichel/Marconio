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


struct AppView: View {
    let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>

    @ObserveInjection var inject

    init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
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

    @State var radioBand: RadioBand = .off

    var body: some View {
        new
        .onAppear {
            viewStore.send(.loadInitialData)
        }
        .enableInjection()
    }

    @ViewBuilder
    var new: some View {
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
                .padding(.top, 3)
                .padding(.horizontal, 8)
                LCDPanelView(store: store)
                    .frame(height: 140)
                BandSelectorView($radioBand, accentColor: Color(rgb: viewStore.settings.accentColor.rawValue))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 5)
                horizontalDivider
                ZStack {
                    // Well
                    VStack {
                        List {
                            ForEach(viewStore.mixtapes) { mixtape in
                                Label("\(mixtape.title)", systemImage: mixtape.systemIcon).onTapGesture {
                                    viewStore.send(.playback(.loadPlayable(MediaPlayable(mixtape: mixtape))))
                                }
                            }
                        }
                    }
                    // Cover
                    SpeakerGrillView()
                        .offset(y: radioBand == .mixtapes ? 300 : 0)
                        .animation(.easeIn(duration: 0.2), value: radioBand)
                        .shadow(color: radioBand == .mixtapes ? .black.opacity(0.3) : .clear, radius: 3, x: 0, y: -5)
                }
            }
        }
        .onChange(of: radioBand, perform: { newValue in
            switch newValue {
            case .off:
                viewStore.send(.playback(.stopPlayback))
            case .channelOne:
                // play channel 1
                let playable = MediaPlayable(channel: viewStore.channels[0])
                viewStore.send(.playback(.loadPlayable(playable)))
            case .channelTwo:
                // play channel 2
                let playable = MediaPlayable(channel: viewStore.channels[1])
                viewStore.send(.playback(.loadPlayable(playable)))
            default:
                // do nothing, we don't want to stop playback until a mix is selected
                break
            }
        })
        .ignoresSafeArea()
    }

    @ViewBuilder
    var basic: some View {
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
    }

    @ViewBuilder
    var horizontalDivider: some View {
        VStack(spacing: 0) {
            Rectangle().frame(height: 0.5)
                .foregroundColor(.black)
            Rectangle().frame(height: 0.5)
                .foregroundColor(.white)
        }.opacity(0.3)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: .init(
                    channels: [],
                    mixtapes: [],
                    playback: .init(currentlyPlaying: nil, playerState: .playing),
                    appDelegate: .init()
                ),
                reducer: AppReducer(api: NoopAPI())
            )
        )
    }
}
