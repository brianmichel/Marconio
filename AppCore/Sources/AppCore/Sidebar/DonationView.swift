//
//  DonationView.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/29/22.
//

import SwiftUI
import Utilities

public struct DonationView: View {
    @State private var waving = false

    public init(waving: Bool = false) {
        self.waving = waving
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "hand.raised")
                        .font(Font.system(size: 50, weight: .light, design: .default))
                        .foregroundColor(.accentColor)
                        .rotationEffect(waving ? .degrees(30) : .degrees(-30), anchor: UnitPoint(x: 0.5, y: 0.8))
                    Text("Please Support NTS").font(.title).bold().allowsTightening(true)
                }
                Spacer()
            }
            Text("NTS is supported by regular listeners just like yourself, so if you support them it keeps the music flowing. They provide a free service to anyone that wants to listen, and there are critically few places producing such a great experience like NTS.")
                .font(.callout)
            Button {
                openDonationLink()
            } label: {
                Text("Become a Supporter").bold().frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
#if os(macOS)
        .frame(width: 350, height: 410)
#endif
        .onAppear {
            withAnimation(.timingCurve(0.7, 0.6, 0.3, 0.8, duration: 1.0).repeatForever().delay(0.4)) {
                waving = true
            }
        }
    }

    private func openDonationLink() {
        let url = URL(string: "https://www.nts.live/supporters")
        url?.openExternally()
    }
}

struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        DonationView().frame(width: 300)
    }
}
