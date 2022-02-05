//
//  MarconioiOSAppDelegate.swift
//  Marconio (iOS)
//
//  Created by Brian Michel on 2/5/22.
//

import AVFoundation
import Foundation
import ComposableArchitecture
import LaceKit
import UIKit

final class MarconioiOSAppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppState(
            channels: [],
            mixtapes: [],
            appDelegateState: .init()
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: .main,
            uuid: UUID.init,
            api: LiveAPI(),
            appDelegate: .init()
        )
    )

    lazy var viewStore = ViewStore(
        self.store.scope(state: { _ in () }),
        removeDuplicates: ==
    )

    override init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    //MARK: UIApplicationDelegate

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        viewStore.send(.appDelegate(.willFinishLaunching))

        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        viewStore.send(.appDelegate(.didFinishLaunching))

        return true
    }

    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        viewStore.send(.appDelegate(.continueActivity(userActivity)))

        return true
    }
}
