//
//  LiveUntilButton.swift
//  Marconio
//
//  Created by Brian Michel on 2/20/22.
//

import SwiftUI
import Models

struct LiveUntilButton: View {
    let channel: Channel

    @State private var popoverPresented = false

    var body: some View {
        Button {
            popoverPresented.toggle()
        } label: {
            VStack {
                Text("Live Until").font(.headline)
                Text(channel.now.endTimestamp.formatted(date: .omitted, time: .shortened))
                    .font(.footnote)
                    .bold()
            }
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $popoverPresented) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Up Next").bold()
                    Spacer()
                    Text(channel.next.startTimestamp.formatted(date: .omitted, time: .shortened))
                }
                Divider()
                Text(channel.next.details?.description ?? "No description provided.")
            }
            .padding()
            .frame(width: 200)
        }
    }
}

struct LiveUntilButton_Previews: PreviewProvider {
    static var previews: some View {
        LiveUntilButton(channel: .mock)
    }
}
