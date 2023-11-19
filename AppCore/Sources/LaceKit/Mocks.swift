//
//  Mocks.swift
//  
//
//  Created by Brian Michel on 2/8/22.
//

import Combine
import Foundation
import Models

public final class NoopAPI: NTSAPI {
    public func live() throws -> AnyPublisher<LiveBroadcastsResponse, RunnerError> {
        return Just(LiveBroadcastsResponse(results: [], links: [])).setFailureType(to: RunnerError.self).eraseToAnyPublisher()
    }

    public func live() async throws -> LiveBroadcastsResponse {
        return LiveBroadcastsResponse(results: [], links: [])
    }

    public func mixtapes() throws -> AnyPublisher<MixtapesResponse, RunnerError> {
        return Just(MixtapesResponse(results: [], links: [])).setFailureType(to: RunnerError.self).eraseToAnyPublisher()
    }

    public func mixtapes() async throws -> MixtapesResponse {
        return MixtapesResponse(results: [], links: [])
    }

    public init() {}
}

#if DEBUG
public final class FailingAPI: NTSAPI {
    public func live() throws -> AnyPublisher<LiveBroadcastsResponse, RunnerError> {
        return Fail(error: RunnerError.network(error: "Unimplemented in Mock")).eraseToAnyPublisher()
    }

    public func live() async throws -> LiveBroadcastsResponse {
        fatalError("unimplemented")
    }

    public func mixtapes() throws -> AnyPublisher<MixtapesResponse, RunnerError> {
        return Fail(error: RunnerError.network(error: "Unimplemented in Mock")).eraseToAnyPublisher()
    }

    public func mixtapes() async throws -> MixtapesResponse {
        fatalError("unimplemented")
    }

    public init() {}
}
#endif
