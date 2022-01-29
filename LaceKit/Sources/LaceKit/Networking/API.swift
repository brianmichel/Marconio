//
//  API.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
import Combine

public protocol NTSAPI {
    func live() throws -> AnyPublisher<LiveBroadcastsResponse, RunnerError>
    func mixtapes() throws -> AnyPublisher<MixtapesResponse, RunnerError>
}

public enum APIError: Error {
    case badPath
}

public final class LiveAPI: NTSAPI {
    private let runner = Runner()


    public init() {}

    public func live() throws -> AnyPublisher<LiveBroadcastsResponse, RunnerError> {
        guard let url = url(for: "live") else {
            throw APIError.badPath
        }

        return runner.requestPublisher(for: URLRequest(url: url))
    }

    public func mixtapes() throws -> AnyPublisher<MixtapesResponse, RunnerError> {
        guard let url = url(for: "mixtapes") else {
            throw APIError.badPath
        }

        return runner.requestPublisher(for: URLRequest(url: url))
    }

    private func url(for path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "nts.live"
        components.path = "/api/v2/\(path)"

        return components.url
    }
}
