//
//  SharingMenu.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 2/8/22.
//

import SwiftUI
import AppKit

public struct SharingMenu: View {
    var items: [Any]

    @State private var services: [NSSharingService] = []

    public init(items: [Any]) {
        self.items = items
    }

    public var body: some View {
        Menu {
            Button(action: {
                if let pasteboardItems = items as? [NSPasteboardWriting] {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects(pasteboardItems)
                }
            }) {
                Image(systemName: "doc.on.doc.fill")
                Text("Copy")
            }
            ForEach(services) { service in
                Button(action: {
                    service.perform(withItems: items)
                }) {
                    Image(nsImage: service.image)
                    Text(service.title)
                }
            }
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .menuIndicator(.hidden)
        .onAppear {
            services = NSSharingService.sharingServices(forItems: items)
        }
    }
}

struct SharingMenu_Previews: PreviewProvider {
    static var previews: some View {
        SharingMenu(items: ["Hello world"])
    }
}

extension NSSharingService: Identifiable {}
