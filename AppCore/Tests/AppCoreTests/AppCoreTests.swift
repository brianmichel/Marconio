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
        let state = AppReducer.State(channels: [],
                             mixtapes: [],
                             playback: .init(),
                             appDelegateState: .init())

        let store = TestStore(initialState: state,
                              reducer: AppReducer())

        store.send(.loadInitialData)

        store.receive(.channelsResponse(.success(.init(results: [], links: []))))
        store.receive(.mixtapesResponse(.success(.init(results: [], links: []))))

        store.send(.loadChannels)

        store.receive(.channelsResponse(.success(.init(results: [], links: []))))

        store.send(.loadMixtapes)

        store.receive(.mixtapesResponse(.success(.init(results: [], links: []))))
    }
}


