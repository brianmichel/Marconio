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
            VStack {
                SettingsGridView(views: [
                    [AnyView(Text("App updates:")), AnyView(Toggle(isOn: .constant(false), label: { Text("Check for updates automatically").fixedSize()}))],
                    [AnyView(EmptyGridCell()), AnyView(Button(action: {}, label: { Text("Check for update now")} ))],
                    [AnyView(Divider()), AnyView(EmptyGridCell())],
                    [AnyView(Text("Menu bar icon:").fixedSize()), AnyView(Toggle(isOn: .constant(false), label: { Text("Show Marconio in menu bar").fixedSize()}))],
                    [AnyView(Text("Click menu bar icon to do:").fixedSize()), AnyView(picker.fixedSize())],
                    [AnyView(EmptyGridCell()), AnyView(Text("This might not do anything if you're on an iOS device.").font(.subheadline)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .lineLimit(2)
                                                        .foregroundColor(.secondary)
                                                      )
                    ],
                ]) { grid in
                    grid.mergeCells(inHorizontalRange: NSRange(location: 0, length: 2),
                                    verticalRange: NSRange(location: 2, length: 1))
                    let cell = grid.cell(atColumnIndex: 0, rowIndex: 2)
                    cell.row?.topPadding = 5
                    cell.row?.bottomPadding = 5

                    grid.cell(atColumnIndex: 0, rowIndex: 3).row?.bottomPadding = 15
                    grid.cell(atColumnIndex: 0, rowIndex: 3).row?.topPadding = 5
                }
            }
            .tabItem {
                Label("General", systemImage: "switch.2")
            }
            .padding()
            .tag(Tabs.general)
            VStack {
                SettingsGridView(views: [
                    [AnyView(Text("General:")), AnyView(Button(action: {}, label: { Text("Hi")} ))]
                ])
            }
            .tabItem {
                Label("About", systemImage: "macwindow")
            }
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
        SettingsView().frame(width: 400)
    }
}
