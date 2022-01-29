//
//  DonationView.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/29/22.
//

import SwiftUI

struct DonationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "hand.raised")
                        .font(Font.system(size: 50, weight: .light, design: .default))
                        .foregroundColor(.accentColor)
                    Text("Please Support NTS").font(.title).bold()
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
            .buttonBorderShape(.roundedRectangle)
            .controlSize(.large)

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
