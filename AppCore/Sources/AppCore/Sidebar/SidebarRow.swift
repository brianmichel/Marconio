//
//  SidebarRow.swift
//  Marconio
//
//  Created by Brian Michel on 2/9/22.
//

import SwiftUI
import Models

struct SidebarRow: View {
    let channel: Channel
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text("Channel \(channel.channelName)")
                Text("\(channel.now.broadcastTitle)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: "radio")
        }
    }
}


struct SidebarRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SidebarRow(channel: .mock)
        }
    }
}
