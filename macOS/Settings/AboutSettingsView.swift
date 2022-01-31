//
//  AboutSettingsView.swift
//  Marconio (macOS)
//
//  Created by Brian Michel on 1/30/22.
//

import SwiftUI
import Preferences

struct AboutSettingsView: View {

    private let contentWidth: Double = 300.0

    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "") {
                VStack(spacing: 5) {
                    Image(nsImage: NSImage(named: "AppIcon")!)
                        .resizable()
                        .frame(width: 150, height: 150)
                    Text("Marconi \(MarconioVersionInformation.macVersionNumber)").font(.largeTitle)

                    Form {
                        Section(footer: footer()) {
                            Label(title: {
                                Text("\(MarconioVersionInformation.buildNumber)")
                            }, icon: {
                                Image(systemName: "clock.fill")
                            })
                                .font(Font.system(.body, design: .monospaced))
                                .help("The build number of the application.")
                                .foregroundColor(.secondary)
                            Label(title: {
                                Text("\(MarconioVersionInformation.gitRevision)")
                            }, icon: {
                                Image(systemName: "hammer.fill")
                            })
                                .font(Font.system(.body, design: .monospaced))
                                .help("The Git SHA the application was built from.")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }

    func footer() -> some View {
        return Label(title: {
            Link("@brianmichel", destination: URL(string: "https://twitter.com/brianmichel")!)
        }, icon: {
            Image(systemName: "link")
        })
            .font(Font.system(.body, design: .monospaced))
            .help("Drop me a message if you have some time.")
    }
}

struct AboutSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettingsView()
    }
}

