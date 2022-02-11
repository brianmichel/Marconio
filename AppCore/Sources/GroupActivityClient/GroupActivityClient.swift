//
//  File.swift
//  
//
//  Created by Brian Michel on 2/10/22.
//

import ComposableArchitecture
import Foundation
import GroupActivities

public struct ListenTogether: GroupActivity {
    public static let activityIdentifier: String = "me.foureyes.marconio.group-activity.listen"

    public var metadata: GroupActivityMetadata {
        var data = GroupActivityMetadata()
        data.type = .listenTogether
        data.title = "Testing"

        return data
    }
}

public struct GroupActivityClient {
    public var advertise: () -> Effect<Action, Error>
    public var listen: () -> Effect<Action, Error>

    public enum Action: Equatable {
        case didStartAdvertising
        case configureSession(GroupSession<ListenTogether>)
    }

    public enum Error: Swift.Error {
        case unableToActivate
    }
}
