//
//  PlayerView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI
import LaceKit

struct PlayerView: View {
    let core: PlayerCore
    @State var playing = false

    var body: some View {
        VStack {
            VStack {
                AsyncImage(url: core.playable.artwork) { image in
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
                            Text(core.playable.title).font(.title).bold()
                            if let subtitle = core.playable.subtitle {
                                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            if playing {
                                core.stop()
                            } else {
                                core.play()
                            }

                            playing.toggle()
                        } label: {
                            Image(systemName: playing ? "pause.circle.fill": "play.circle.fill").resizable().frame(width: 35, height: 35)
                        }
                        .foregroundColor(.accentColor)
                        .buttonStyle(.plain)
                        .keyboardShortcut(.space)
                    }
                    Text(core.playable.description).font(.body)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }.frame(width: 300)
            }
            Spacer()
        }.onDisappear {
            core.stop()
        }
    #if os(macOS)
        .frame(width: 350, height: 410)
    #endif
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(core: PlayerCore(playable: Mixtape.placeholder))
    }
}
