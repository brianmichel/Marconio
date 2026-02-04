//
//  BandSelectorView.swift
//  Marconio
//
//  Created by Brian Michel on 1/22/23.
//

import Dependencies
import HapticsClient
import SwiftUI
import Inject

enum RadioBand: Int {
    case off
    case channelOne
    case channelTwo
    case mixtapes
}

struct BandSelectorView: View {
    @ObserveInjection var inject

    @Dependency(\.hapticsClient) var hapticsClient

    private var binding: Binding<RadioBand>
    private var accentColor: Color
    @State private var value: Int = 0

    init(_ binding: Binding<RadioBand>, accentColor: Color = .white) {
        self.binding = binding
        self.accentColor = accentColor
    }

    var body: some View {
        BandSelectorSliderView($value, accentColor: accentColor)
        .onChange(of: value, perform: { newValue in
            self.binding.wrappedValue = RadioBand(rawValue: newValue)!
            hapticsClient.play()
        })
        .enableInjection()
    }
}

struct BandSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        BandSelectorView(.constant(.channelTwo))
    }
}
