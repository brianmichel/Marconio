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

    @State private var location: CGFloat = 0
    @Binding private var binding: Int

    private var labelFont: Font {
        .system(.callout).uppercaseSmallCaps()
    }

    init(_ binding: Binding<Int>, range: ClosedRange<Int> = 0...3, accentColor: Color = .white) {
        _binding = binding
        self.range = range
        self.accentColor = accentColor
    }

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

    var body: some View {
        VStack(spacing: 5) {
            labels
            GeometryReader { gr in
                let thumbWidth = gr.size.height * 1.8
                let thumbHeight = gr.size.height * 0.75
                let radius = gr.size.height
                let minValue = gr.size.width * 0.010
                let maxValue = (gr.size.width * 0.99) - thumbWidth / 2

                let offsets = (maxValue / CGFloat(range.count - 1))

                let lower = range.lowerBound
                let upper = range.upperBound
                let detentRange = Range(uncheckedBounds: (lower+1, upper))
                let padding = binding == lower ? 0 : thumbWidth/2
                let calculatedOffset = CGFloat(binding) * offsets - padding

                let sliderOffset = calculatedOffset.clamped(to: minValue...maxValue)

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
                            .offset(x: sliderOffset)
                            .gesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { value in
                                        self.location = value.location.x
                                        self.binding = Int(self.location / offsets).clamped(to: 0...3)
                                    }
                                    .onEnded({ value in
                                        self.location = 0
                                    })
                            )
                        Spacer()
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
