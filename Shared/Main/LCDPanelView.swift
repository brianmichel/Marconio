//
//  LCDPanelView.swift
//  Marconio
//
//  Created by Brian Michel on 1/21/23.
//

import AppCore
import ComposableArchitecture
import Models
import PlaybackCore
import SwiftUI

struct LCDPanelView: View {
    private struct ViewState: Equatable {
        var playbackState: PlaybackReducer.State

        init(state: AppReducer.State) {
            self.playbackState = state.playback
        }
    }

    private let viewStore: ViewStore<ViewState, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)))
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .padding([.horizontal], 8)
                .padding([.vertical], 5)
                .foregroundColor(Color(rgb: 0xB0B0B0))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(Color(rgb: 0xBF5B1F).opacity(0.8))
                        .padding([.horizontal], 8)
                        .padding([.vertical], 5)
                )
                .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: 1)
                .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: -1)
            VStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    let titles = title(for: viewStore.playbackState.currentlyPlaying)
                    Text(titles.0)
                        .font(.dseg(22, weight: .bold))
                        .foregroundColor(Color(rgb: 0x262626))
                    Text(titles.1)
                        .font(.dseg(22, weight: .bold))
                        .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                }
                Spacer().frame(height: 8)
                ZStack(alignment: .leading) {
                    let subtitles = subtitle(for: viewStore.playbackState.currentlyPlaying)
                    Text(subtitles.0)
                        .font(.dseg(13, weight: .bold))
                        .foregroundColor(Color(rgb: 0x262626))
                    Text(subtitles.1)
                        .font(.dseg(13, weight: .bold))
                        .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                }
                Spacer()
                HStack {
                    HStack {
                        let location = location(for: viewStore.playbackState.currentlyPlaying)
                        ZStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 15).bold())
                                .foregroundColor(Color(rgb: 0x262626))
                                .opacity(location != nil ? 1.0 : 0.0)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 15).bold())
                                .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                                .offset(x: 0.8, y: 0.8)

                        }
                        ZStack(alignment: .leading) {
                            Text(location ?? "")
                                .font(.dseg(15, weight: .regular))
                                .foregroundColor(Color(rgb: 0x262626))
                            Text("888888888888888888")
                                .font(.dseg(15, weight: .regular))
                                .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                        }
                    }

                    Spacer()
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 15).bold())
                        .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                }
            }
            .padding(.horizontal)
            .frame(height: 120)
        }
    }

    private func location(for playable: MediaPlayable?) -> String? {
        guard let playable, let source = playable.source else { return nil }

        switch source {
        case .left(let channel):
            return channel.now.details?.locationLong?.uppercased()
        case .right(_):
            return nil
        }
    }

    private func title(for playable: MediaPlayable?) -> (String, String) {
        let backing = String(repeating: "8", count: 16)
        guard let playable else {
            return  ("NOT!PLAYING", backing)
        }

        let replaced = playable.title.replacingOccurrences(of: " ", with: "!")

        return (replaced, backing)
    }

    private func subtitle(for playable: MediaPlayable?) -> (String, String) {
        let maxCharacters = 27
        let backing = String(repeating: "8", count: maxCharacters)
        guard let playable, var subtitle = playable.subtitle else {
            return  ("", backing)
        }

        let difference = subtitle.count - maxCharacters
        if difference > 0 {
            subtitle = String(subtitle.dropLast(difference))
        }
        let replaced = subtitle.replacingOccurrences(of: " ", with: "!")

        return (replaced, backing)
    }
}
