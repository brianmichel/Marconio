//
//  PlayerView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

struct PlayerView: View {
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    var playable: MediaPlayable

    init(playable: MediaPlayable, store: Store<PlaybackState, PlaybackAction>) {
        self.playable = playable
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            VStack {
                AsyncImage(url: playable.artwork) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    PlayableArtworkPlaceholderView()
                }
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(playable.title).font(.title).bold()
                            if let subtitle = playable.subtitle {
                                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            if !isPlayingBackCurrentPlayable {
                                viewStore.send(.loadPlayable(playable))
                            } else {
                                let action = appIsPlaying ? PlaybackAction.pausePlayback : PlaybackAction.resumePlayback
                                viewStore.send(action)
                            }
                        } label: {
                            Image(systemName: playOrPauseIconImage).resizable().frame(width: 35, height: 35)
                        }
                        .foregroundColor(.accentColor)
                        .buttonStyle(.plain)
                        .keyboardShortcut(.space)
                    }
                    Text(playable.description).font(.body)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }.frame(width: 300)
            }
            Spacer()
        }
    #if os(macOS)
        .frame(width: 350, height: 410)
    #endif
    }

    var appIsPlaying: Bool {
        return viewStore.playerState == .playing
    }

    var isPlayingBackCurrentPlayable: Bool {
        return viewStore.currentlyPlaying == playable
    }

    var playOrPauseIconImage: String {
        if !isPlayingBackCurrentPlayable {
            return "play.circle.fill"
        } else if appIsPlaying {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            playable: MediaPlayable(mixtape: Mixtape.placeholder),
            store: Store(
                initialState: PlaybackState(),
                reducer: playbackReducer,
                environment: PlaybackEnvironment()
            )
        )
    }
}
