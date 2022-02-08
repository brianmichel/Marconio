//
//  AppCoreTests.swift
//  
//
//  Created by Brian Michel on 2/8/22.
//

@testable import AppCore
import ComposableArchitecture
import AppDelegate
import LaceKit
import XCTest

class AppCoreTests: XCTestCase {
    func testIntegration() {
        let state = AppState(channels: [],
                             mixtapes: [],
                             playback: .init(),
                             appDelegateState: .init())

        let environment = AppEnvironment(mainQueue: .immediate,
                                         uuid: UUID.init,
                                         api: NoopAPI(),
                                         appDelegate: AppDelegateEnvironment(),
                                         dbClient: .noop)

        let store = TestStore(initialState: state,
                              reducer: appReducer,
                              environment: environment)

        store.send(.loadInitialData)

        store.receive(.channelsResponse(.success(.init(results: [], links: []))))
        store.receive(.mixtapesResponse(.success(.init(results: [], links: []))))

        store.send(.loadChannels)

        store.receive(.channelsResponse(.success(.init(results: [], links: []))))

        store.send(.loadMixtapes)

        store.receive(.mixtapesResponse(.success(.init(results: [], links: []))))
    }
}


