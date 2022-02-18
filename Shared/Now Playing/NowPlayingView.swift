//
//  NowPlayingView.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/29/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit
import PlaybackCore
import AVFoundation
import MediaPlayer
import Models

struct NowPlayingView: View {
    private enum C {
        static let nowPlayingNaturalHeight = 64.0
        static let playPauseTapAreaExpansion = -200.0
        static let iconSize = 25.0
        static let routeViewWidth = 40.0
    }
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    init(store: Store<PlaybackState, PlaybackAction>) {
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: playOrPauseIconImage)
                        .font(Font.system(size: C.iconSize, weight: .bold, design: .default))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.space, modifiers: [])
                Spacer().frame(width: 10)
                VStack(alignment: .leading, spacing: 5) {
                    let text = viewStore.currentlyPlaying?.title ?? "Nothing Playing"
                    MarqueeText(
                        text: text,
                        font: MFont.boldSystemFont(ofSize: 16),
                        leftFade: 10,
                        rightFade: 10,
                        startDelay: 10,
                        alignment: .leading
                    )
                    if let subtitle = viewStore.currentlyPlaying?.subtitle {
                        MarqueeText(
                            text: subtitle,
                            font: MFont.systemFont(ofSize: 13, weight: .light),
                            leftFade: 10,
                            rightFade: 10,
                            startDelay: 10,
                            alignment: .leading
                        )
                    }
                }
                Spacer()
                if let picker = viewStore.routePickerView {
                    picker.frame(width: C.routeViewWidth)
                }
            }
            Spacer()
        }
        .frame(height: C.nowPlayingNaturalHeight)
    }

    var playOrPauseIconImage: String {
        switch viewStore.playerState {
        case .stopped:
            return "play.fill"
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        }
    }

    private func togglePlayback() {
        viewStore.send(.togglePlayback)
    }
}

struct NowPlayingView_Previews: PreviewProvider {
    #if os(macOS)
    static var routePicker = RoutePickerView(routePickerButtonBordered: false, player: AVPlayer())
    #else
    static var routePicker = RoutePickerView(player: AVPlayer())
    #endif

    static var previews: some View {
        Group {
            NowPlayingView(
                store: Store(
                    initialState: PlaybackState(),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            )
                .preferredColorScheme(.dark)

            NowPlayingView(
                store: Store(
                    initialState: PlaybackState(
                        currentlyPlaying: MediaPlayable(mixtape: .placeholder),
                        playerState: .playing,
                        routePickerView: routePicker
                    ),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            )
                .frame(width: 200)
                .preferredColorScheme(.light)
        }
    }
}
