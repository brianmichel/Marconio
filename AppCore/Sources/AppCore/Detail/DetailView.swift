//
//  DetailView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI
import ComposableArchitecture
import LaceKit
import Models
import PlaybackCore

struct DetailView: View {
    @ObservedObject var viewStore: ViewStore<PlaybackReducer.State, PlaybackReducer.Action>

    var playable: MediaPlayable
    @State private var shareSheetPresented = false
    @State private var popoverPresented = false

    init(playable: MediaPlayable, store: StoreOf<PlaybackReducer>) {
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
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.primary.opacity(0.2), lineWidth: 1))
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                if case let .left(channel) = playable.source {
                    LiveUntilButton(channel: channel)
                } else {
                    EmptyView()
                }
            }
            ToolbarItem {
                Spacer()
            }
            ToolbarItem {
                #if os(macOS)
                // Share a string here since macOS is finicky about the specific types of copied items.
                SharingMenu(items: [playable.url.absoluteString])
                #else
                    Button(action: { shareSheetPresented.toggle() }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                #endif
            }
        }
        #if os(iOS)
        .sheet(isPresented: $shareSheetPresented, onDismiss: nil) {
            ShareSheet(items: [playable.url])
        }
        #endif

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
                    initialState: PlaybackReducer.State(),
                    reducer: PlaybackReducer()
                )
            )
                .padding()
                .preferredColorScheme(.dark)

            DetailView(
                playable: MediaPlayable(mixtape: Mixtape.placeholder),
                store: Store(
                    initialState: PlaybackReducer.State(),
                    reducer: PlaybackReducer()
                )
            )
                .padding()
                .preferredColorScheme(.light)
        }
    }
}
