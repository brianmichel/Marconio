//
//  PlayableArtworkPlaceholderView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI

@available(iOS 15, macOS 12, *)
public struct PlayableArtworkPlaceholderView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.secondary
            Image(systemName: "music.note.list")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.primary.opacity(0.4))
        }.containerShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

@available(iOS 15, macOS 12, *)
public struct PlayableArtworkPlaceholderView_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            PlayableArtworkPlaceholderView()
                .frame(width: 300, height: 300)
            PlayableArtworkPlaceholderView()
                .frame(width: 100, height: 100).preferredColorScheme(.light)

        }
    }
}
