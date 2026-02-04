//
//  MixtapeListView.swift
//  Marconio
//

import SwiftUI
import Models
import PlaybackCore

enum MixtapeListStyle {
    /// Accent-colored title with a description line beneath, speaker icon on the right when playing.
    case standard
    /// Each row gets a subtle background tint when it is the currently playing mixtape.
    case highlighted
}

struct MixtapeListView: View {
    let mixtapes: [Mixtape]
    let currentlyPlaying: MediaPlayable?
    let accentColor: Color
    let style: MixtapeListStyle
    let onSelect: (Mixtape) -> Void

    init(mixtapes: [Mixtape],
         currentlyPlaying: MediaPlayable? = nil,
         accentColor: Color = .white,
         style: MixtapeListStyle = .standard,
         onSelect: @escaping (Mixtape) -> Void) {
        self.mixtapes = mixtapes
        self.currentlyPlaying = currentlyPlaying
        self.accentColor = accentColor
        self.style = style
        self.onSelect = onSelect
    }

    var body: some View {
        List {
            ForEach(mixtapes) { mixtape in
                let playable = MediaPlayable(mixtape: mixtape)
                let isPlaying = currentlyPlaying == playable
                MixtapeRowView(
                    mixtape: mixtape,
                    isPlaying: isPlaying,
                    accentColor: accentColor,
                    style: style
                )
                .accessibilityHint(isPlaying
                    ? "Currently playing. Tunes the radio to this mixtape."
                    : "Tunes the radio to this mixtape."
                )
                .onTapGesture {
                    onSelect(mixtape)
                }
            }
        }
    }
}

// MARK: - Row

private struct MixtapeRowView: View {
    let mixtape: Mixtape
    let isPlaying: Bool
    let accentColor: Color
    let style: MixtapeListStyle

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: mixtape.systemIcon)
                    Text("\(mixtape.title)")
                }
                .font(.body.bold())
                .foregroundColor(accentColor)
                Text(mixtape.description)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Spacer()
            // Fixed-width column so the icon appearing never reflows the text
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(accentColor)
                .font(.caption)
                .frame(width: 16)
                .opacity(isPlaying ? 1 : 0)
        }
        .padding(.vertical, style == .highlighted ? 4 : 0)
        .background(
            style == .highlighted && isPlaying
                ? accentColor.opacity(0.08)
                : Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: style == .highlighted ? 6 : 0))
    }
}

// MARK: - Previews

private func previewMixtape(alias: String, title: String, description: String) -> Mixtape {
    var m = Mixtape.placeholder
    m.mixtapeAlias = alias
    m.title = title
    m.description = description
    return m
}

private let previewMixtapes: [Mixtape] = [
    previewMixtape(alias: "poolside",    title: "Poolside",    description: "Whisk yourself away with an unlimited supply of NTS' most sun-kissed mixes."),
    previewMixtape(alias: "labyrinth",   title: "Labyrinth",   description: "Lose yourself in atmospheric breaks, tripped out techno, and cerebral electronics."),
    previewMixtape(alias: "feelings",    title: "Feelings",    description: "Warm your soul with our anthology of emotive popular music from the 20th century."),
    previewMixtape(alias: "the-tube",    title: "The Tube",    description: "Rip it up and start again as we explore the differing strains of avant-garde music."),
    previewMixtape(alias: "heartlands",  title: "Heartlands",  description: "Expand your musical knowledge with an NTS archive of recorded folk traditions."),
]

#Preview("Standard — nothing playing") {
    ZStack {
        Color(rgb: 0x262626)
        MixtapeListView(
            mixtapes: previewMixtapes,
            currentlyPlaying: nil,
            accentColor: Color(rgb: 0xBF5B1F),
            style: .standard,
            onSelect: { _ in }
        )
    }
}

#Preview("Standard — Labyrinth playing") {
    ZStack {
        Color(rgb: 0x262626)
        MixtapeListView(
            mixtapes: previewMixtapes,
            currentlyPlaying: MediaPlayable(mixtape: previewMixtapes[1]),
            accentColor: Color(rgb: 0xBF5B1F),
            style: .standard,
            onSelect: { _ in }
        )
    }
}

#Preview("Highlighted — Feelings playing") {
    ZStack {
        Color(rgb: 0x262626)
        MixtapeListView(
            mixtapes: previewMixtapes,
            currentlyPlaying: MediaPlayable(mixtape: previewMixtapes[2]),
            accentColor: Color(rgb: 0x64BF1F),
            style: .highlighted,
            onSelect: { _ in }
        )
    }
}

#Preview("Highlighted — The Tube playing (blue accent)") {
    ZStack {
        Color(rgb: 0x262626)
        MixtapeListView(
            mixtapes: previewMixtapes,
            currentlyPlaying: MediaPlayable(mixtape: previewMixtapes[3]),
            accentColor: Color(rgb: 0x1FB3BF),
            style: .highlighted,
            onSelect: { _ in }
        )
    }
}
