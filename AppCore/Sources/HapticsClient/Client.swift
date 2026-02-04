//
//  File.swift
//  
//
//  Created by Brian Michel on 1/25/23.
//

import AppKit
import Dependencies

public struct HapticsClient {
    public var play: () -> Void
}

public extension HapticsClient {
    static var live: Self {
        return Self(
            play: {
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
            }
        )
    }
}

extension HapticsClient: DependencyKey {
    public static var liveValue: HapticsClient = .live
}

extension DependencyValues {
    public var hapticsClient: HapticsClient {
        get { self[HapticsClient.self] }
        set { self[HapticsClient.self] = newValue }
    }
}
