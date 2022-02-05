//
//  SettingsView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/4/22.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, about
    }

    var body: some View {
        TabView {
            GeneralSettingsView()
            .tabItem {
                Label("General", systemImage: "switch.2")
            }
            .frame(width: 450)
            .tag(Tabs.general)
            AboutSettingsView()
            .tabItem {
                Label("About", systemImage: "macwindow")
            }
            .frame(width: 250)
            .tag(Tabs.about)
        }
    }

    var picker: some View {
        return Picker(selection: .constant(1)) {
            Text("Nothing").tag(1)
            Text("Something").tag(2)
        } label: {
            EmptyView()
        }
        .pickerStyle(.automatic)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().frame(width: 350)
    }
}
