//
//  BandSelectorView.swift
//  Marconio
//
//  Created by Brian Michel on 1/22/23.
//

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

    private var binding: Binding<RadioBand>
    @State private var value: Int = 0

    init(_ binding: Binding<RadioBand>) {
        self.binding = binding
    }

    var body: some View {
        BandSelectorSliderView($value)
        .onChange(of: value, perform: { newValue in
            self.binding.wrappedValue = RadioBand(rawValue: newValue)!
        })
        .enableInjection()
    }
}

struct BandSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        BandSelectorView(.constant(.channelTwo))
    }
}
