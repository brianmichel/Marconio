//
//  HomeView.swift
//  Shared
//
//  Created by Brian Michel on 1/27/22.
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
import LaceKit
#endif

struct HomeView: View {
    @ObservedObject var core = HomeCore()
    @State var searchText = ""

    var body: some View {
        NavigationView {
            List {
                Section("Live") {
                    ForEach(core.channels) { channel in
                        NavigationLink(destination: PlayerView(core: PlayerCore(playable: channel))) {
                            Label("Channel \(channel.channelName)", systemImage: "radio")
                        }
                    }
                }

                Section("Infinite Mixtapes") {
                    ForEach(core.mixtapes) { mixtape in
                        NavigationLink(destination: PlayerView(core: PlayerCore(playable: mixtape))) {
                            Label("\(mixtape.title)", systemImage: mixtape.systemIcon)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Channels")
            #if os(macOS)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: core.update, label: {
                        Image(systemName: "arrow.clockwise")
                    }).keyboardShortcut(KeyEquivalent("r"), modifiers: [.command])
                }
            }
            #endif
            Text("Now Playing").font(.largeTitle)
        }
    }

    private func toggleSidebar() { // 2
    #if os(iOS)
    #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    #endif
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
