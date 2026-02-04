//
//  StationSelectorView.swift
//  Marconio
//

import SwiftUI
import Models
import PlaybackCore
#if canImport(AppKit)
import AppKit
#endif

/// A 2×3 grid of preset station buttons, inspired by car-stereo presets.
/// Buttons 1–2 are fixed to Channel 1 and Channel 2.
/// Buttons 3–6 are user-assignable mixtape shortcuts (in-memory).
struct StationSelectorView: View {
    let mixtapes: [Mixtape]
    let accentColor: Color

    /// The item currently being played, used to highlight the active preset.
    let currentlyPlaying: MediaPlayable?

    /// Called when a channel or assigned-mixtape preset is tapped.
    let onPlay: (MediaPlayable) -> Void

    /// In-memory shortcut slots for presets 3–6.  Index 0 = preset 3, etc.
    @State private var shortcuts: [Mixtape?] = [nil, nil, nil, nil]

    /// Which preset slot (0-based into `shortcuts`) currently has its popover open.
    @State private var assigningSlot: Int? = nil

    private func haptic() {
        #if canImport(AppKit)
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        #endif
    }

    var body: some View {
        let columns: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
        LazyVGrid(columns: columns, spacing: 6) {
            channelButton(number: 1, channelIndex: 0)
            channelButton(number: 2, channelIndex: 1)
            ForEach(0..<4) { slot in
                mixtapePresetButton(number: slot + 3, slot: slot)
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Channel buttons (fixed)

    private func channelButton(number: Int, channelIndex: Int) -> some View {
        let playable = channelPlayable(index: channelIndex)

        // TODO: This is busted due to playable.id being 'channel-1' and currentlyPlay?.id being '1'
        let isSelected = currentlyPlaying?.id == playable.id
        return Button {
            haptic()
            onPlay(playable)
        } label: {
            PresetButtonLabel(
                number: number,
                state: .channel(index: channelIndex),
                accentColor: accentColor,
                isSelected: isSelected
            )
        }
        .buttonStyle(PresetButtonStyle(isSelected: isSelected))
        .focusEffectDisabled()
        .keyboardShortcut(KeyEquivalent(Character(String(number))))
    }

    // MARK: - Mixtape preset buttons (assignable)

    private func mixtapePresetButton(number: Int, slot: Int) -> some View {
        let mixtape = shortcuts[slot]
        let isSelected = mixtape.map { currentlyPlaying?.id == MediaPlayable(mixtape: $0).id } ?? false
        return Button {
            haptic()
            if let mixtape {
                onPlay(MediaPlayable(mixtape: mixtape))
            } else {
                assigningSlot = slot
            }
        } label: {
            PresetButtonLabel(
                number: number,
                state: mixtape.map { .assigned($0) } ?? .empty,
                accentColor: accentColor,
                isSelected: isSelected
            )
        }
        .buttonStyle(PresetButtonStyle(isSelected: isSelected))
        .focusEffectDisabled()
        .keyboardShortcut(KeyEquivalent(Character(String(number))))
        .contextMenu {
            if mixtape != nil {
                Button("Change") {
                    assigningSlot = slot
                }
                Button("Remove", role: .destructive) {
                    shortcuts[slot] = nil
                }
            }
        }
        .popover(isPresented: Binding(
            get: { assigningSlot == slot },
            set: { if !$0 { assigningSlot = nil } }
        )) {
            MixtapePickerPopover(
                mixtapes: mixtapes,
                accentColor: accentColor,
                currentSelection: mixtape,
                onSelect: { mixtape in
                    shortcuts[slot] = mixtape
                    assigningSlot = nil
                }
            )
        }
    }

    /// Synthesise a minimal MediaPlayable for a channel index so the parent
    /// can match on it. The parent should replace this with real channel data.
    private func channelPlayable(index: Int) -> MediaPlayable {
        MediaPlayable(
            id: "channel-\(index + 1)",
            title: "Channel \(index + 1)",
            subtitle: nil,
            description: "",
            artwork: URL(string: "https://nts.live")!,
            url: URL(string: "https://nts.live")!,
            streamURL: URL(string: "https://stream-relay-geo.ntslive.net/stream\(index == 0 ? "" : "2")")!,
            source: nil
        )
    }
}

// MARK: - Preset button label

/// The visual content of a single preset button.
private enum PresetState {
    case channel(index: Int)
    case assigned(Mixtape)
    case empty
}

private struct PresetButtonLabel: View {
    let number: Int
    let state: PresetState
    let accentColor: Color
    var isSelected: Bool = false

    /// Dims colors when the button is pressed/selected to enhance depth illusion
    private var depthDimming: Double { isSelected ? 0.6 : 1.0 }

    var body: some View {
        VStack(spacing: 2) {
            switch state {
            case .channel:
                Text("\(number)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(accentColor.opacity(depthDimming))
                Text("CH")
                    .font(.caption.weight(.bold).uppercaseSmallCaps())
                    .foregroundColor(.secondary.opacity(depthDimming))
            case .assigned(let mixtape):
                Text("\(number)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(accentColor.opacity(depthDimming))
                Image(systemName: mixtape.systemIcon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(depthDimming))
            case .empty:
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary.opacity(0.4 * depthDimming))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .padding(.vertical, 6)
        .blendMode(.colorDodge)
        .opacity(0.7)
    }
}

// MARK: - Button style

/// Tactile hardware-style button inspired by Pioneer car stereo presets.
/// Resting state shows a raised button with visible side walls.
/// Pressing or selection pushes it down into the bezel.
private struct PresetButtonStyle: ButtonStyle {
    let isSelected: Bool

    private let buttonDepth: CGFloat = 6
    private let cornerRadius: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        let depressed = configuration.isPressed || isSelected
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        let pressOffset: CGFloat = depressed ? buttonDepth - 0.5 : 0

        // Colors
        let faceColorTop = Color(rgb: depressed ? 0x1E1E1E : 0x3A3A3A)
        let faceColorBottom = Color(rgb: depressed ? 0x161616 : 0x2A2A2A)
        let wallRight = Color(rgb: 0x282828)   // Right wall - catches some light
        let wallBottom = Color(rgb: 0x121212)  // Bottom wall - in shadow
        let wellColor = Color(rgb: 0x0A0A0A)

        return configuration.label
            .padding(.bottom, buttonDepth)
            .background {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let r = cornerRadius

                    ZStack(alignment: .topLeading) {
                        // The recessed well the button sits in
                        shape
                            .fill(wellColor)
                            .overlay {
                                shape
                                    .strokeBorder(Color.black, lineWidth: 1)
                            }

                        // Bottom wall (visible when raised)
                        if !depressed {
                            // Bottom face of the 3D extrusion
                            Path { path in
                                path.move(to: CGPoint(x: r, y: h - buttonDepth))
                                path.addLine(to: CGPoint(x: w - r, y: h - buttonDepth))
                                path.addLine(to: CGPoint(x: w - r, y: h))
                                path.addQuadCurve(
                                    to: CGPoint(x: w, y: h - r),
                                    control: CGPoint(x: w, y: h)
                                )
                                path.addLine(to: CGPoint(x: w, y: h - buttonDepth - r))
                                path.addLine(to: CGPoint(x: 0, y: h - buttonDepth - r))
                                path.addLine(to: CGPoint(x: 0, y: h - r))
                                path.addQuadCurve(
                                    to: CGPoint(x: r, y: h),
                                    control: CGPoint(x: 0, y: h)
                                )
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    colors: [wallBottom.opacity(0.8), wallBottom],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }

                        // Right wall (visible when raised)
                        if !depressed {
                            Path { path in
                                path.move(to: CGPoint(x: w, y: r))
                                path.addLine(to: CGPoint(x: w, y: h - r))
                                path.addQuadCurve(
                                    to: CGPoint(x: w - r, y: h),
                                    control: CGPoint(x: w, y: h)
                                )
                                path.addLine(to: CGPoint(x: w - r, y: h - buttonDepth))
                                path.addLine(to: CGPoint(x: w - buttonDepth, y: h - buttonDepth))
                                path.addLine(to: CGPoint(x: w - buttonDepth, y: r))
                                path.closeSubpath()
                            }
                            .fill(
                                LinearGradient(
                                    colors: [wallRight, wallRight.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }

                        // Top face (the part you press)
                        shape
                            .fill(
                                LinearGradient(
                                    colors: [faceColorTop, faceColorBottom],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: w, height: h - buttonDepth)
                            // Convex dome highlight
                            .overlay {
                                shape
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                .white.opacity(depressed ? 0.02 : 0.12),
                                                .clear
                                            ],
                                            center: .init(x: 0.3, y: 0.2),
                                            startRadius: 0,
                                            endRadius: max(w, h) * 0.7
                                        )
                                    )
                            }
                            // Bevel edge highlight (top-left lit, bottom-right shadow)
                            .overlay {
                                shape.strokeBorder(
                                    LinearGradient(
                                        colors: depressed
                                            ? [.black.opacity(0.6), .white.opacity(0.03)]
                                            : [.white.opacity(0.4), .white.opacity(0.15), .black.opacity(0.35)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                            }
                            // Top edge gleam
                            .overlay {
                                if !depressed {
                                    shape
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.25), .clear, .clear, .clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            }
                            // Inner shadow when pressed
                            .overlay {
                                if depressed {
                                    shape
                                        .strokeBorder(Color.black.opacity(0.5), lineWidth: 3)
                                        .blur(radius: 2)
                                        .mask(shape)
                                }
                            }
                            .offset(y: pressOffset)
                    }
                }
            }
            .clipShape(shape)
            .animation(.easeOut(duration: 0.06), value: configuration.isPressed)
    }
}

// MARK: - Mixtape picker popover

/// The popover content shown when tapping an unassigned preset.
private struct MixtapePickerPopover: View {
    let mixtapes: [Mixtape]
    let accentColor: Color
    let currentSelection: Mixtape?
    let onSelect: (Mixtape) -> Void

    var body: some View {
        List {
            ForEach(mixtapes) { mixtape in
                Button {
                    onSelect(mixtape)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 5) {
                                Image(systemName: mixtape.systemIcon)
                                Text(mixtape.title)
                            }
                            .font(.body.bold())
                            .foregroundColor(accentColor)
                            Text(mixtape.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if currentSelection?.id == mixtape.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(accentColor)
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .listStyle(.plain)
        .frame(width: 260, height: min(CGFloat(mixtapes.count) * 56 + 20, 340))
    }
}

// MARK: - Previews

private let previewMixtapes: [Mixtape] = {
    func m(_ alias: String, _ title: String, _ desc: String) -> Mixtape {
        var m = Mixtape.placeholder
        m.mixtapeAlias = alias
        m.title = title
        m.description = desc
        return m
    }
    return [
        m("poolside",   "Poolside",    "Sun-kissed mixes to whisk yourself away."),
        m("labyrinth",  "Labyrinth",   "Atmospheric breaks and cerebral electronics."),
        m("feelings",   "Feelings",    "Emotive popular music from the 20th century."),
        m("the-tube",   "The Tube",    "Avant-garde music, ripped up and started again."),
        m("heartlands", "Heartlands",  "Folk traditions from the NTS archive."),
        m("expansions", "Expansions",  "Expansive soundscapes and deep cuts."),
    ]
}()

/// A minimal MediaPlayable stand-in so we can seed `currentlyPlaying` in previews.
private func previewPlayable(id: String) -> MediaPlayable {
    MediaPlayable(
        id: id, title: id, subtitle: nil, description: "",
        artwork: URL(string: "https://nts.live")!,
        url: URL(string: "https://nts.live")!,
        streamURL: URL(string: "https://nts.live")!,
        source: nil
    )
}

#Preview("All empty") {
    ZStack {
        Color(rgb: 0x262626)
        StationSelectorView(
            mixtapes: previewMixtapes,
            accentColor: Color(rgb: 0xBF5B1F),
            currentlyPlaying: previewPlayable(id: "channel-1"),
            onPlay: { _ in }
        )
        .frame(width: 320)
    }
}

#Preview("Some assigned") {
    // We can't set @State from outside, so this just shows the empty state.
    // Open in Xcode and tap presets 3–6 to assign from the popover.
    ZStack {
        Color(rgb: 0x262626)
        StationSelectorView(
            mixtapes: previewMixtapes,
            accentColor: Color(rgb: 0x64BF1F),
            currentlyPlaying: nil,
            onPlay: { _ in }
        )
        .frame(width: 320)
    }
}

#Preview("Blue accent") {
    ZStack {
        Color(rgb: 0x262626)
        StationSelectorView(
            mixtapes: previewMixtapes,
            accentColor: Color(rgb: 0x1FB3BF),
            currentlyPlaying: nil,
            onPlay: { _ in }
        )
        .frame(width: 320)
    }
}
#Preview("Picker popover") {
    MixtapePickerPopover(
        mixtapes: previewMixtapes,
        accentColor: Color(rgb: 0xBF5B1F),
        currentSelection: previewMixtapes[1],
        onSelect: { _ in }
    )
}
