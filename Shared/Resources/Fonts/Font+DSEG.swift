//
//  Font+DSEG.swift
//  Marconio
//
//  Created by Brian Michel on 1/21/23.
//

import SwiftUI

enum DSEGWeight: String {
    case bold = "Bold"
    case boldItalic = "BoldItalic"
    case italic = "Italic"
    case light = "Light"
    case lightItalic = "LightItalic"
    case regular = "Regular"
}

extension Font {
    static func dseg(_ size: CGFloat, weight: DSEGWeight) -> Font {
        return .custom("DSEG14Classic-\(weight.rawValue)", size: size)
    }
}
