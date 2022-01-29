//
//  PlayableArtworkPlaceholderView.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import SwiftUI

struct PlayableArtworkPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.secondary
            Image(systemName: "music.note.list")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.primary)
        }.containerShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct PlayableArtworkPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlayableArtworkPlaceholderView()
            .frame(width: 300, height: 300)
    }
}
