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

    /// Drives the countdown timer; ticks every second while a channel broadcast is active.
    @State private var now = Date()
    /// Continuously updates so the LCD-breath shader can animate.
    @State private var shaderTime: Float = 0

    init(store: StoreOf<AppReducer>) {
        self.viewStore = ViewStore(store, observe: { .init(state: $0) })
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            glowLayer
            background
            VStack(alignment: .leading, spacing: 4) {
                // Row 2: Title
                LCDSegmentedTextView(
                    text: title(for: viewStore.playback.currentlyPlaying),
                    maximumCharacters: 16,
                    fontSize: 22,
                    fontWeight: .bold
                )
                .padding(.top, 4)

                // Row 3: Subtitle
                LCDSegmentedTextView(
                    text: subtitle(for: viewStore.playback.currentlyPlaying),
                    maximumCharacters: 27,
                    fontSize: 13
                )

                Spacer()

                // Bottom bar: location
                HStack {
                    locationView
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .overlay(insetBorder)
        .frame(height: 120)
        .onTapGesture {
            viewStore.send(.settings(.nextAccentColor), animation: .easeInOut(duration: 0.5))
        }
        // 1-second timer for the countdown; only runs while there's an end timestamp to count down to
        .onAppear { now = Date() }
        .modifier(CountdownTicker(endTimestamp: endTimestamp(for: viewStore.playback.currentlyPlaying), now: $now))
        // High-frequency ticker for the shader breath animation — only while audio is active
        .background {
            if viewStore.playback.playerState != .stopped {
                TimelineView(.animation) { context in
                    Color.clear.onChange(of: context.date) { newDate in
                        shaderTime = Float(newDate.timeIntervalSince1970.truncatingRemainder(dividingBy: 3600))
                    }
                }
            }
        }
    }

    // MARK: - Glow layer

    /// A blurred accent-coloured shape behind the panel. The colorEffect shader
    /// modulates it with animated noise so the glow is organic rather than uniform.
    @ViewBuilder
    private var glowLayer: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(Color(rgb: viewStore.settings.accentColor.rawValue))
            .padding([.horizontal], 8)
            .padding([.vertical], 5)
            .blur(radius: 12)
            .opacity(0.6)
            .modifier(LCDGlowModifier(time: shaderTime))
    }

    // MARK: - Background

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
            // Fine edge definition
            .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: 1)
            .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: -1)
            .accessibilityHidden(true)
    }

    // MARK: - Location

    @ViewBuilder
    private var locationView: some View {
        let loc = location(for: viewStore.playback.currentlyPlaying)
        HStack(spacing: 2) {
            ZStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 13).bold())
                    .foregroundColor(Color(rgb: 0x262626))
                    .opacity(loc != nil ? 0.8 : 0.0)
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 13).bold())
                    .foregroundColor(Color(rgb: 0x262626).opacity(0.2))
                    .offset(x: 0.8, y: 0.8)
            }
            LCDSegmentedTextView(
                text: loc ?? "",
                maximumCharacters: 3,
                fontSize: 13
            )
        }
    }

    // MARK: - Data helpers

    private func location(for playable: MediaPlayable?) -> String? {
        guard let playable, let source = playable.source else { return nil }
        switch source {
        case .left(let channel):
            return channel.now.details?.locationShort
        case .right:
            return "MIX"
        }
    }

    private func title(for playable: MediaPlayable?) -> String {
        guard let playable else { return "Not playing" }
        return playable.title
    }

    private func subtitle(for playable: MediaPlayable?) -> String {
        guard let playable, let subtitle = playable.subtitle else { return "" }
        return subtitle
    }

    private func endTimestamp(for playable: MediaPlayable?) -> Date? {
        guard let playable, let source = playable.source else { return nil }
        switch source {
        case .left(let channel):
            return channel.now.endTimestamp
        case .right:
            return nil
        }
    }

    // MARK: - Inset border

    /// A recessed-bezel border: dark shadow on the top & left edges,
    /// light highlight on the bottom & right, giving the LCD an inset look.
    @ViewBuilder
    private var insetBorder: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.black.opacity(0.1), lineWidth: 1)   // highlight (bottom-right feel via composite)
            .padding([.horizontal], 8)
            .padding([.vertical], 5)
            .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)   // dark cast (top-left)
            .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: -1) // light bounce (bottom-right)
    }
}
// MARK: - LCDGlowModifier

/// Applies the noise-modulation colorEffect to the glow layer.
/// Gated behind availability because ShaderLibrary requires macOS 14+ / iOS 17+.
private struct LCDGlowModifier: ViewModifier {
    let time: Float

    func body(content: Content) -> some View {
        if #available(macOS 14, iOS 17, *) {
            content.colorEffect(
                ShaderLibrary.default.lcdGlowNoise(.float(time))
            )
        } else {
            content
        }
    }
}

// MARK: - LiveBadgeView

/// "LIVE" text that flashes on and off like an LCD segment being switched.
private struct LiveBadgeView: View {
    @State private var visible = true

    var body: some View {
        LCDSegmentedTextView(
            text: "LIVE",
            maximumCharacters: 4,
            fontSize: 10,
            fontWeight: .bold
        )
        .opacity(visible ? 0.8 : 0.15)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                visible = false
            }
        }
    }
}

// MARK: - CountdownTicker

/// A ViewModifier that publishes a tick every second into `now` while
/// `endTimestamp` is non-nil (i.e. a live broadcast is active).
private struct CountdownTicker: ViewModifier {
    let endTimestamp: Date?
    @Binding var now: Date

    func body(content: Content) -> some View {
        content
            .onChange(of: endTimestamp) { _ in
                now = Date()
            }
            .background {
                if endTimestamp != nil {
                    TimelineView(.periodic(from: Date(), by: 1.0)) { context in
                        Color.clear.onChange(of: context.date) { newDate in
                            now = newDate
                        }
                    }
                }
            }
    }
}



