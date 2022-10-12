//
//  Mocks.swift
//  
//
//  Created by Brian Michel on 2/6/22.
//

import ComposableArchitecture

extension UserActivityClient: TestDependencyKey {
    public static var testValue: UserActivityClient = Self (
        becomeCurrent: { _ in .failing("\(Self.self).becomeCurrent is unimplemented")},
        handleActivity: { _ in .failing("\(Self.self).handleActivity is unimplemented")}
    )
    public static var previewValue: UserActivityClient = Self(
        becomeCurrent: { _ in .none },
        handleActivity: { _ in .none }
    )
}



