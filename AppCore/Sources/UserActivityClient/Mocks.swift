//
//  Mocks.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import ComposableArchitecture

public extension UserActivityClient {
    #if DEBUG
    static let failing = Self (
        becomeCurrent: { _ in .failing("\(Self.self).becomeCurrent is unimplemented")},
        resignCurrent: { .failing("\(Self.self).resignCurrent is unimplemented")},
        handleActivity: { _ in .failing("\(Self.self).handleActivity is unimplemented")}
    )
    #endif
    static let noop = Self(
        becomeCurrent: { _ in .none },
        resignCurrent: { .none },
        handleActivity: { _ in .none }
    )
}



