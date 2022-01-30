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
        do {
            let request = try request(for: "live")
            return runner.requestPublisher(for: request)
        } catch {
            throw APIError.badPath
        }
    }

    public func mixtapes() throws -> AnyPublisher<MixtapesResponse, RunnerError> {
        do {
            let request = try request(for: "mixtapes")
            return runner.requestPublisher(for: request)
        } catch {
            throw APIError.badPath
        }
    }

    private func url(for path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "nts.live"
        components.path = "/api/v2/\(path)"

        return components.url
    }

    private func request(for path: String) throws -> URLRequest {
        guard let url = url(for: path) else {
            throw APIError.badPath
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy

        return request
    }
}
