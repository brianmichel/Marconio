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
import AppCore
import AppDelegate
import AppDelegate_iOS

final class MarconioiOSAppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: .init(),
        reducer: AppReducer(api: LiveAPI())
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
}
