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
        var playback: PlaybackReducer.State
        var settings: SettingsReducer.State

        init(state: AppReducer.State) {
            self.playback = state.playback
            self.settings = state.settings
        }
    }

    private let viewStore: ViewStore<ViewState, AppReducer.Action>

    init(store: StoreOf<AppReducer>) {
        self.viewStore = ViewStore(store, observe: { .init(state: $0) })
    }

    var body: some View {
        ZStack {
            background
            VStack(alignment: .leading) {
                LCDSegmentedTextView(
                    text: title(for: viewStore.playback.currentlyPlaying),
                    maximumCharacters: 16,
                    fontSize: 22,
                    fontWeight: .bold
                )
                Spacer().frame(height: 8)
                LCDSegmentedTextView(
                    text: subtitle(for: viewStore.playback.currentlyPlaying),
                    maximumCharacters: 27,
                    fontSize: 13
                )
                Spacer()
                HStack {
                    HStack(spacing: 2) {
                        let location = location(for: viewStore.playback.currentlyPlaying)
                        ZStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 15).bold())
                                .foregroundColor(Color(rgb: 0x262626))
                                .opacity(location != nil ? 0.8 : 0.0)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 15).bold())
                                .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                                .offset(x: 0.8, y: 0.8)

                        }
                        LCDSegmentedTextView(
                            text: location ?? "",
                            maximumCharacters: 3,
                            fontSize: 15
                        )
                    }

                    Spacer()
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 15).bold())
                        .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                    playPauseButton
                }
            }
            .padding(.horizontal)
            .frame(height: 120)
        }
        .onTapGesture {
            viewStore.send(.settings(.nextAccentColor), animation: .easeInOut(duration: 0.5))
        }
    }

    @ViewBuilder
    var background: some View {
        RoundedRectangle(cornerRadius: 4)
            .padding([.horizontal], 8)
            .padding([.vertical], 5)
            .foregroundColor(Color(rgb: 0xB0B0B0))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(Color(rgb: viewStore.settings.accentColor.rawValue).opacity(0.8))
                        .padding([.horizontal], 8)
                        .padding([.vertical], 5)
                        .background {
                            Image("lcd_texture").resizable(resizingMode: .tile)
                                .opacity(0.8)
                                .padding([.horizontal], 10)
                                .padding([.vertical], 8)
                        }
                }
            )
            .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: 1)
            .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: -1)
            .accessibilityHidden(true)
    }

    private func location(for playable: MediaPlayable?) -> String? {
        guard let playable, let source = playable.source else { return nil }

        switch source {
        case .left(let channel):
            return channel.now.details?.locationShort
        case .right(_):
            return nil
        }
    }

    private func title(for playable: MediaPlayable?) -> String {
        guard let playable else {
            return  "Not playing"
        }

        return playable.title
    }

    private func subtitle(for playable: MediaPlayable?) -> String {
        guard let playable, let subtitle = playable.subtitle else {
            return  ""
        }

        return subtitle
    }

    @ViewBuilder
    private var playPauseButton: some View {
        let isPlaying = viewStore.playback.playerState == .playing
        let icon = isPlaying ? "pause.circle" : "play.circle"
        let action: AppReducer.Action = isPlaying ? .playback(.pausePlayback) : .playback(.resumePlayback)

        let isStopped = viewStore.playback.playerState == .stopped
        Button {
            viewStore.send(action)
        } label: {
            ZStack {
                if !isStopped {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(rgb: 0x262626).opacity(0.8))
                }
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                    .offset(x: 0.8, y: 0.8)
            }
        }
        .contentShape(Circle())
        .disabled(isStopped)
        .buttonStyle(.plain)
    }
}
