//
//  API.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
import Combine
import Models

/// A portocol describing the API functionality within an NTS client.
public protocol NTSAPI {
    /**
     Fetch the data describing what's currently live on https://nts.live

     - Throws: An ``APIError`` descirbing why the request could not have been made.
     - Returns: A publisher with either an `LiveBroadcastsResponse` or an ``RunnerError`` depending on what happened.
     */
    func live() async throws -> LiveBroadcastsResponse

    /**
     Fetch the data describing what infinite mixtapes are available on https://nts.live

     - Throws: An ``APIError`` descirbing why the request could not have been made.
     - Returns: A publisher with either an `MixtapesResponse` or an ``RunnerError`` depending on what happened.
     */
    func mixtapes() async throws -> MixtapesResponse

}

/// Errors returned by the API construction layer, not to be confused with ``RunnerError`` which returns errors from actually performing a request.
public enum APIError: Error {
    /// Unable to construct the path that was requested
    case badPath
}

public final class LiveAPI: NTSAPI {
    private let runner = Runner()

    public init() {}

    public func live() async throws -> LiveBroadcastsResponse {
        let request = try request(for: "live")
        return try await runner.request(for: request)
    }

    public func mixtapes() async throws -> MixtapesResponse {
        let request = try request(for: "mixtapes")
        return try await runner.request(for: request)
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
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        return request
    }
}
