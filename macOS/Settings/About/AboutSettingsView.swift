//
//  AboutSettingsView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/5/22.
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
            Text("Marconio").font(.title)
            Spacer().frame(height: 20)
            Text("\(MarconioVersionInformation.macVersionNumber) (\(MarconioVersionInformation.buildNumber))")
            Text("\(MarconioVersionInformation.gitRevision)").font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
    }
}

struct AboutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettingsView()
    }
}
