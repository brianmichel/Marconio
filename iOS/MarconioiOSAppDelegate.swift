//
//  MarconioiOSAppDelegate.swift
//  Marconio (iOS)
//
//  Created by Brian Michel on 2/5/22.
//

import Foundation
import ComposableArchitecture
import LaceKit
import UIKit


final class MarconioiOSAppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppState(
            channels: [],
            mixtapes: []
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: .main,
            uuid: UUID.init,
            api: LiveAPI()
        )
    )

    lazy var viewStore = ViewStore(
        self.store.scope(state: { _ in () }),
        removeDuplicates: ==
    )
}
