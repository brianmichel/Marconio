//
//  SettingsView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 1/30/22.
//

import SwiftUI
import Preferences


extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let about = Self("about")
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, about
    }

    private enum C {
        static let minWidth: CGFloat = 300
        static let maxWidth: CGFloat = 400
        static let minHeight: CGFloat = 300
        static let maxHeight: CGFloat = 400

    }

    var body: some View {
        TabView {
            GeneralSettingsView().padding()
            .tag(Tabs.general)
            .tabItem {
                Label("General", systemImage: "gearshape.fill")
            }
            AboutSettingsView()
            .tag(Tabs.about)
            .tabItem {
                Label("About", systemImage: "books.vertical.fill")
            }
        }
        .frame(
            minWidth: C.minWidth,
            maxWidth: C.maxWidth,
            minHeight: C.minHeight,
            maxHeight: C.maxHeight
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
