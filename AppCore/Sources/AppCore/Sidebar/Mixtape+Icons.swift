//
//  Mixtape+Icons.swift
//  Lace
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
import LaceKit
import Models

extension Mixtape {
    var systemIcon: String {
        switch mixtapeAlias {
        case "poolside":
            return "bell.slash"
        case "labyrinth":
            return "person.fill.questionmark"
        case "feelings":
            return "heart"
        case "the-tube":
            return "amplifier"
        case "heartlands":
            return "globe"
        case "expansions":
            return "paintbrush"
        case "100-percent-hip-hop":
            return "brain"
        case "sweat":
            return "megaphone"
        case "memory-lane":
            return "hourglass"
        case "island-time":
            return "fanblades"
        case "slow-focus":
            return "bolt.batteryblock"
        case "4-to-the-floor":
            return "metronome"
        case "rap-house":
            return "quote.bubble"
        case "field-recordings":
            return "recordingtape"
        default:
            return "radio"
        }
    }
}
