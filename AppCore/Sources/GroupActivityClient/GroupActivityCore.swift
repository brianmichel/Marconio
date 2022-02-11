//
//  File.swift
//  
//
//  Created by Brian Michel on 2/10/22.
//

import ComposableArchitecture
import Foundation
import GroupActivities

public struct GroupActivityState: Equatable {
    public var advertising = false
    public var session: GroupSession<ListenTogether>?
    public var messenger: GroupSessionMessenger?

    public init(advertising: Bool = false,
                session: GroupSession<ListenTogether>? = nil,
                messenger: GroupSessionMessenger? = nil) {
        self.advertising = advertising
        self.session = session
        self.messenger = messenger
    }
}

public struct GroupActivityEnvironment {
    public var client: GroupActivityClient
    public var mainQueue: AnySchedulerOf<DispatchQueue> = .main

    public init(client: GroupActivityClient) {
        self.client = client
    }
}

public enum GroupActivityAction: Equatable {
    case startAdvertising
    case startSharedListening
    case client(Result<GroupActivityClient.Action, GroupActivityClient.Error>)
}

public let groupActivityReducer = Reducer<GroupActivityState, GroupActivityAction, GroupActivityEnvironment> {
    state, action, environment in
    switch action {
    case .startAdvertising:
        return environment.client.advertise()
            .receive(on: environment.mainQueue)
            .catchToEffect(GroupActivityAction.client)
    case .startSharedListening:
        return environment.client.listen()
            .receive(on: environment.mainQueue)
            .catchToEffect(GroupActivityAction.client)
    case let .client(.success(.configureSession(listeningSession))):
        state.session = listeningSession
        state.messenger = GroupSessionMessenger(session: listeningSession)
        return .none
    case .client(.failure(_)):
        return .none
    case .client(.success(.didStartAdvertising)):
        state.advertising = true
        return .none
    }
}

extension GroupSession: Equatable {
    public static func == (lhs: GroupSession<ActivityType>, rhs: GroupSession<ActivityType>) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GroupSessionMessenger: Equatable {
    public static func == (lhs: GroupSessionMessenger, rhs: GroupSessionMessenger) -> Bool {
        return false
    }
}
