//
//  Runner.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
import Combine

/// An error describing what kind of issue there was performing or handling the request.
public enum RunnerError: Error, Equatable {
    /**
     An error originating from attempting to send the request over the network.

     - Parameters:
        - error: A string describing the underlying error
     */
    case network(error: String)

    /**
     An error originating from attempting to decode the response data of a request.

     - Parameters:
        - error: A string describing the underlying error
     */
    case decoder(error: String)
}

/// Used to actually perform network requests with a shared `URLSession`.
public final class Runner {
    private let session = URLSession(configuration: .default)

    /**
     Perform a request and attempt to map it to a specific type conforming to `Codable`.

     A basic example of how to use the request publisher would be as follows:
     ```
     struct MyResponse: Codable {}

     func runTestRequest() -> AnyPublisher<MyResponse, RunnerError> {
     return runner.requestPublisher(for: request)
     }
     ```

     - Warning: The type you supply *must* conform to the `Codable` protocol.
     - Parameters:
        - request: The request that should be given to the underlying `URLSession`

     - Returns: A publisher containing the `Result` type with either a *T* on success, or `RunnerError` on failure.
     */
    public func requestPublisher<T: Codable>(for request: URLRequest) -> AnyPublisher<T, RunnerError> {
        session.dataTaskPublisher(for: request)
            .mapError({ error in
            .network(error: error.localizedDescription)
            })
            .flatMap({ response in
                self.requestDecoder(for: response.data)
            })
            .eraseToAnyPublisher()
    }

    public func request<T: Codable>(for request: URLRequest) async throws -> T {
        let response = try await session.data(for: request)
        return try self.decoder(for: response.0)
    }
}

extension Runner {
    func requestDecoder<T: Codable>(for data: Data) -> AnyPublisher<T, RunnerError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return Just(data)
            .tryMap({ decodable in
                try decoder.decode(T.self, from: decodable)
            })
            .mapError({ error in
            .decoder(error: error.localizedDescription)
            })
            .eraseToAnyPublisher()
    }

    func decoder<T: Codable>(for data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(T.self, from: data)
    }
}
