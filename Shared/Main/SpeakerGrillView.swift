//
//  SpeakerGrillView.swift
//  Marconio
//
//  Created by Brian Michel on 1/21/23.
//

import SwiftUI
import Inject

struct SpeakerGrillView: View {
    @ObserveInjection var inject
    @State var scaling: Bool = false
    var body: some View {
        ZStack {
            grillMeshForground
            mediumFineMesh
                .mask {
                    Circle()
                        .scaleEffect(scaling ? 0.98 : 1)
                        .padding()
                }
                .shadow(color: .secondary.opacity(0.2), radius: 0.4, x: 0, y: 0.3)
                .foregroundColor(.black)
            mediumFineMesh
                .foregroundColor(.black.opacity(0.7))
                .shadow(color: .primary.opacity(0.2), radius: 0.4, x: 0, y: 0.3)

                .opacity(0.8)
        }
        .enableInjection()
    }

    @ViewBuilder
    var fineMesh: some View {
        Image(decorative: "fine_mesh")
            .resizable(capInsets: EdgeInsets(
                top: 2,
                leading: 2,
                bottom: 2,
                trailing: 2),
                       resizingMode: .tile
            )
    }

    @ViewBuilder
    var mediumFineMesh: some View {
        Image(decorative: "medium_fine_mesh")
            .resizable(capInsets: EdgeInsets(
                top: 4,
                leading: 4,
                bottom: 1,
                trailing: 1),
                       resizingMode: .tile
            )
    }

    @ViewBuilder
    var grillMeshForground: some View {
        Rectangle()
            .foregroundColor(Color(rgb: 0x434343))
    }
}

struct SpeakerGrilleView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerGrillView().frame(width: 320)
    }
}