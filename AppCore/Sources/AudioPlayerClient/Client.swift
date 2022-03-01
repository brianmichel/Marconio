//
//  Client.swift
//  
//
//  Created by Brian Michel on 2/28/22.
//

import AVFoundation
import ComposableArchitecture
import Foundation
import Models

public struct AudioPlayerClient {
    public var load: (MediaPlayable) -> Effect<Action, Failure>
    public var play: () -> Effect<Never, Never>
    public var pause: () -> Effect<Never, Never>
    public var stop: () -> Effect<Never, Never>

    public enum Action: Equatable {
        case didLoad(AVPlayer)
    }

    public enum Failure: Error, Equatable {
        case unableToLoad
    }
}
