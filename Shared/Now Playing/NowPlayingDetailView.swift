//
//  NowPlayingDetailView.swift
//  Marconio
//
//  Created by Brian Michel on 2/20/22.
//

import ComposableArchitecture
import PlaybackCore
import Models
import SwiftUI

struct NowPlayingDetailView: View {
    private let store: Store<PlaybackState, PlaybackAction>
    @ObservedObject var viewStore: ViewStore<PlaybackState, PlaybackAction>

    @State private var shareSheetPresented = false

    init(store: Store<PlaybackState, PlaybackAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var title: some View {
        guard let playable = viewStore.currentlyPlaying else {
            return Text("Unknown Sounds".uppercased()).toAnyView()
        }

        switch playable.source {
        case .left(_):
            return LiveView().frame(height: 20).toAnyView()
        case .right(_):
            return Text("infinite mixtape".uppercased()).toAnyView()
        case .none:
            return Text("unknown sounds".uppercased()).toAnyView()
        }
    }


    var description: String {
        return viewStore.currentlyPlaying?.description ?? "A description has not been provided."
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        title
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if let playable = viewStore.currentlyPlaying {
                            Menu {
                                Section {
#if os(macOS)
                                    // Share a string here since macOS is finicky about the specific types of copied items.
                                    SharingMenu(items: [playable.url.absoluteString])
#else
                                    Button(action: { shareSheetPresented.toggle() }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
#endif
                                    Button(action: {
                                        playable.url.openExternally()
                                    }) {
                                        Label("Open website", systemImage: "arrow.up.right.square.fill")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .menuStyle(.borderlessButton)
                            .menuIndicator(.hidden)
                            .fixedSize()
#if os(iOS)
                            .sheet(isPresented: $shareSheetPresented, onDismiss: nil) {
                                ShareSheet(items: [playable.url])
                            }
#endif
                        }
                    }
                    Spacer().frame(height: 10)
                    Text(description)
                }
            }
            Divider()
        }
    }
}

struct NowPlayingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NowPlayingDetailView(store: Store(
                initialState: PlaybackState(currentlyPlaying: MediaPlayable(mixtape: .placeholder)),
                reducer: playbackReducer,
                environment: PlaybackEnvironment()
            ))
                .frame(width: 400)
                .preferredColorScheme(.light)

            NowPlayingDetailView(store: Store(
                initialState: PlaybackState(),
                reducer: playbackReducer,
                environment: PlaybackEnvironment()
            ))
                .frame(width: 400)
                .preferredColorScheme(.dark)
        }

    }
}
