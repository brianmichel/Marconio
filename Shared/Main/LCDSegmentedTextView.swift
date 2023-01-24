//
//  LCDSegmentedTextView.swift
//  Marconio
//
//  Created by Brian Michel on 1/22/23.
//

import SwiftUI
import Inject

struct LCDSegmentedTextView: View {
    let text: String
    let foregroundColor: Color
    let maximumCharacters: Int
    let fontSize: CGFloat
    let fontWeight: DSEGWeight

    @ObserveInjection var inject

    init(text: String, foregroundColor: Color = Color(rgb: 0x262626), maximumCharacters: Int = 20, fontSize: CGFloat = 15, fontWeight: DSEGWeight = .regular) {
        self.text = text
        self.foregroundColor = foregroundColor
        self.maximumCharacters = maximumCharacters
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }

    private var font: Font {
        .dseg(fontSize, weight: fontWeight)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            let trimmed = trimmed(text: text)
            Text(trimmed.0)
                .font(font)
                .foregroundColor(foregroundColor.opacity(0.7))
                .shadow(color: .black.opacity(0.4), radius: 0.9, x: 0, y: -0.5)
            Text(trimmed.1)
                .font(font)
                .foregroundColor(foregroundColor.opacity(0.1))
        }
        .enableInjection()
    }

    private func trimmed(text: String) -> (String, String, Bool) {
        let backing = String(repeating: "~", count: maximumCharacters)

        // We need to clean up our string to make it work with
        // the DSEG font...
        let difference = text.count - maximumCharacters
        var truncatedText = text
        var wasTruncated = false
        if difference > 0 {
            truncatedText = String(text.dropLast(difference))
            wasTruncated = true
        }

        let replaced = truncatedText
            .replacingOccurrences(of: " ", with: "!")
            // `:` must be converted to something to not break
            // the illusion of the display.
            .replacingOccurrences(of: ":", with: "-")

        return (replaced, backing, wasTruncated)
    }
}

struct LCDSegmentedTextView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LCDSegmentedTextView(text: "Hello world, this is longer than ", foregroundColor: .red)
            LCDSegmentedTextView(text: "London", foregroundColor: .primary)
            LCDSegmentedTextView(text: "NTS GUIDE TO: DUTCH PUNK, POST PUNK, SYNTH & OTHER ODDITIES 1979-1989", foregroundColor: .secondary, fontSize: 25, fontWeight: .bold)
        }
    }
}
