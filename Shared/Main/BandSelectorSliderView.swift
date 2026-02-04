//
//  BandSelectorSliderView.swift
//  Marconio
//
//  Created by Brian Michel on 1/22/23.
//

import AppCore
import SwiftUI

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#if swift(<5.1)
extension Strideable where Stride: SignedInteger {
    func clamped(to limits: CountableClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
#endif

struct BandSelectorSliderView: View {
    private let range: ClosedRange<Int>
    private let showDetents = false
    private let accentColor: Color

    /// The visual x-position of the thumb. Moves freely during drag,
    /// then spring-animates into the nearest detent on release.
    @State private var thumbOffset: CGFloat = 0
    /// The thumbOffset snapshot taken at the start of the current drag,
    /// so we can apply translation deltas rather than using raw location.
    @State private var dragStartOffset: CGFloat = 0
    /// Guards against overwriting thumbOffset during an active drag
    /// when geometry or binding changes trigger a re-layout.
    @State private var isDragging = false
    /// Cached geometry values so onEnded can compute detent positions
    /// without needing to be inside the GeometryReader closure.
    @State private var cachedMaxValue: CGFloat = 0
    @State private var cachedOffsets: CGFloat = 0
    @State private var cachedThumbWidth: CGFloat = 0

    @Binding private var binding: Int

    private var labelFont: Font {
        .system(.callout).uppercaseSmallCaps()
    }

    init(_ binding: Binding<Int>, range: ClosedRange<Int> = 0...3, accentColor: Color = .white) {
        _binding = binding
        self.range = range
        self.accentColor = accentColor
    }

    // MARK: - Detent helpers

    /// The resting x-offset for a given detent index, matching the original layout math.
    /// Accepts explicit geometry so it works correctly even when called in the same
    /// frame that the cached values are first written.
    private func offsetForIndex(
        _ index: Int,
        maxValue: CGFloat? = nil,
        offsets: CGFloat? = nil,
        thumbWidth: CGFloat? = nil
    ) -> CGFloat {
        let mv = maxValue ?? cachedMaxValue
        let of = offsets ?? cachedOffsets
        let tw = thumbWidth ?? cachedThumbWidth
        let trackWidth = (mv + tw / 2) / 0.99
        let minValue = trackWidth * 0.010
        let padding: CGFloat = index == range.lowerBound ? 0 : tw / 2
        let raw = CGFloat(index) * of - padding
        return raw.clamped(to: minValue...mv)
    }

    /// Find the detent index whose resting position is closest to the given offset.
    private func nearestIndex(for x: CGFloat) -> Int {
        var bestIndex = range.lowerBound
        var bestDist = CGFloat.infinity
        for i in range {
            let dist = abs(x - offsetForIndex(i))
            if dist < bestDist {
                bestDist = dist
                bestIndex = i
            }
        }
        return bestIndex
    }

    // MARK: - Labels

    @ViewBuilder
    private var labels: some View {
        HStack {
            Text("OFF")
                .font(labelFont)
            Spacer()
            Text("C1")
                .font(labelFont)
                .offset(x: -12)
            Spacer()
            Text("C2")
                .font(labelFont)
                .offset(x: -6)
            Spacer()
            Image(systemName: "infinity")
                .font(labelFont)
        }
        .opacity(0.7)
        .padding(.horizontal, 5)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 5) {
            labels
            GeometryReader { gr in
                let thumbWidth = gr.size.height * 1.8
                let thumbHeight = gr.size.height * 0.75
                let radius = gr.size.height
                let minValue = gr.size.width * 0.010
                let maxValue = (gr.size.width * 0.99) - thumbWidth / 2

                let offsets = maxValue / CGFloat(range.count - 1)

                let lower = range.lowerBound
                let upper = range.upperBound
                let detentRange = Range(uncheckedBounds: (lower+1, upper))

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(Color(rgb: 0x1E1E1E))
                        .shadow(color: .white.opacity(0.2), radius: 0.5, x: 0, y: 0.8)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .padding(.horizontal, 5)
                                .foregroundColor(.black.opacity(0.3))
                                .shadow(color: .white.opacity(0.2), radius: 0.2, x: 0, y: 0.2)
                        )
                    if showDetents {
                        ForEach(detentRange, id: \.self) { index in
                            Rectangle()
                                .frame(width: 1, height: gr.size.height * 0.80)
                                .offset(x: CGFloat(index) * offsets)
                        }
                    }
                    HStack {
                        slider
                            .frame(width: thumbWidth, height: thumbHeight)
                            .offset(x: thumbOffset)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if !isDragging {
                                            isDragging = true
                                            dragStartOffset = thumbOffset
                                        }
                                        // Raw position from drag delta, clamped to track
                                        let candidate = (dragStartOffset + value.translation.width).clamped(to: minValue...maxValue)

                                        // Magnetic pull: find nearest detent and bias toward it
                                        // when within the snap radius. The pull strengthens as
                                        // you approach center, so you have to actively push through.
                                        let snapRadius: CGFloat = offsets * 0.38
                                        let nearest = nearestIndex(for: candidate)
                                        let detentPos = offsetForIndex(nearest)
                                        let distToDetent = abs(candidate - detentPos)

                                        if distToDetent < snapRadius {
                                            // t goes 0 (at edge of radius) → 1 (at detent center)
                                            let t = 1.0 - (distToDetent / snapRadius)
                                            // Ease the pull so it feels like increasing resistance
                                            let pull = t * t
                                            thumbOffset = candidate + (detentPos - candidate) * pull
                                        } else {
                                            thumbOffset = candidate
                                        }

                                        // Fire haptic when thumb crosses into a new detent
                                        if nearest != binding {
                                            binding = nearest
                                        }
                                    }
                                    .onEnded { value in
                                        isDragging = false
                                        // Snap fully into the nearest detent
                                        let index = nearestIndex(for: thumbOffset)
                                        binding = index
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
                                            thumbOffset = offsetForIndex(index)
                                        }
                                    }
                            )
                        Spacer()
                    }
                }
                // Cache geometry and sync thumb position whenever layout changes
                .onAppear {
                    cachedThumbWidth = thumbWidth
                    cachedMaxValue = maxValue
                    cachedOffsets = offsets
                    thumbOffset = offsetForIndex(binding, maxValue: maxValue, offsets: offsets, thumbWidth: thumbWidth)
                }
                .onChange(of: gr.size) { _ in
                    cachedThumbWidth = thumbWidth
                    cachedMaxValue = maxValue
                    cachedOffsets = offsets
                    if !isDragging {
                        thumbOffset = offsetForIndex(binding, maxValue: maxValue, offsets: offsets, thumbWidth: thumbWidth)
                    }
                }
            }.frame(height: 15)

        }
    }

    @ViewBuilder
    private var slider: some View {
        ZStack {
            Capsule(style: .continuous)
                .foregroundColor(accentColor.opacity(0.9))
                .shadow(radius: 0.2)
            // Draw the grabber texture
            HStack(spacing: 2) {
                Rectangle().frame(width: 1)
                Rectangle().frame(width: 1)
                Rectangle().frame(width: 1)
            }
            //TODO: This color should be synced with the display color
            .foregroundColor(accentColor)
            .padding(.vertical, 2)
            .shadow(radius: 0.8, x: 0.2, y: 0.2)
            .shadow(color: .white.opacity(0.3), radius: 0.2, x: -0.2)
        }
    }
}

struct BandSelectorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        BandSelectorSliderView(.constant(3), range: 0...3)
            .frame(width: 320)
    }
}
