//
//  GeneralSettingsView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/5/22.
//

import SwiftUI
import Sparkle

struct GeneralSettingsView: View {
    @AppStorage("ShouldAutoupdate") private var shouldAutoupdate = true
    private let updater = SPUStandardUpdaterController(startingUpdater: true,
                                                       updaterDelegate: nil,
                                                       userDriverDelegate: nil)
    var body: some View {
        SettingsGridView(views: [
            [AnyView(Text("App updates:")), AnyView(Toggle(isOn: $shouldAutoupdate, label: { Text("Check for updates automatically").fixedSize()}))],
            [AnyView(EmptyGridCell()), AnyView(Button(action: { updater.checkForUpdates(nil) }, label: { Text("Check for update now")} ))]
        ]) { grid in
            grid.row(at: 1).topPadding = 5
        }.padding()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
