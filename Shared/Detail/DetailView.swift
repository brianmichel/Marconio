//
//  DetailView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit

struct DetailView: View {
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    var playable: MediaPlayable

    init(playable: MediaPlayable, store: Store<PlaybackState, PlaybackAction>) {
        self.playable = playable
        viewStore = ViewStore(store)
    }

    var body: some View {
        GeometryReader { reader in
            VStack {
                VStack {
                    AsyncImage(url: playable.artwork) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        PlayableArtworkPlaceholderView()
                    }
                    .frame(width: detailWidth(proxy: reader), height: detailWidth(proxy: reader))
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
                                    viewStore.send(.togglePlayback)
                                }
                            } label: {
                                Image(systemName: playOrPauseIconImage).resizable().frame(width: 35, height: 35)
                            }
                            .foregroundColor(.accentColor)
                            .buttonStyle(.plain)
                        }
                        Text(playable.description).font(.body)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }.frame(width: detailWidth(proxy: reader))
                }
                Spacer()
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
#if os(macOS)
        .frame(width: 350, height: 410)
#endif
    }

    var isPlayingBackCurrentPlayable: Bool {
        return viewStore.currentlyPlaying == playable
    }

    var playOrPauseIconImage: String {
        if !isPlayingBackCurrentPlayable {
            return "play.circle.fill"
        } else if viewStore.playerState == .playing {
            return "pause.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }

    func detailWidth(proxy: GeometryProxy) -> Double {
        #if os(macOS)
        return 350
        #else
        return proxy.size.width
        #endif
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetailView(
                playable: MediaPlayable(mixtape: Mixtape.placeholder),
                store: Store(
                    initialState: PlaybackState(),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            ).preferredColorScheme(.dark)

            DetailView(
                playable: MediaPlayable(mixtape: Mixtape.placeholder),
                store: Store(
                    initialState: PlaybackState(),
                    reducer: playbackReducer,
                    environment: PlaybackEnvironment()
                )
            ).preferredColorScheme(.light)
        }
    }
}
