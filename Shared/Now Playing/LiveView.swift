//
//  LiveView.swift
//  Marconio
//
//  Created by Brian Michel on 3/4/22.
//

import SwiftUI

struct LiveView: View {
    private enum C {
        static let inset = 5.0
    }
    @State private var animating = false
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                HStack(alignment: .center, spacing: 0) {
                    Circle()
                        .inset(by: C.inset)
                        .frame(width: proxy.size.height, height: proxy.size.height)
                        .foregroundColor(.red)
                        .offset(x: -C.inset, y: 0)
                        .opacity(animating ? 1.0 : 0.6)
                        .shadow(color: .red.opacity(0.5), radius: (animating ? 3.0 : 0.3), x: 0, y: 0)
                    Text("LIVE").offset(x: -C.inset)
                }
            }
        }.onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                animating.toggle()
            }
        }
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView().frame(height: 20)
    }
}
