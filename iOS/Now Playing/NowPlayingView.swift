//
//  NowPlayingView.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/29/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

struct NowPlayingView: View {
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    init(store: Store<PlaybackState, PlaybackAction>) {
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(viewStore.currentlyPlaying?.title ?? "Nothing Playing").bold()
                    if let subtitle = viewStore.currentlyPlaying?.subtitle {
                        Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: playOrPauseIconImage)
                        .font(Font.system(size: 25, weight: .bold, design: .default))
                }.buttonStyle(.borderless)

            }.padding(.horizontal)
            Spacer()
        }
        .frame(height: 64)
        .background(.thickMaterial)
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
    static var previews: some View {
        Group {
            NowPlayingView(
                store: Store(
                    initialState: PlaybackState(),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            ).preferredColorScheme(.dark)

            NowPlayingView(
                store: Store(
                    initialState: PlaybackState(
                        currentlyPlaying: MediaPlayable(mixtape: .placeholder),
                        playerState: .playing
                    ),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            ).preferredColorScheme(.light)
        }
    }
}
