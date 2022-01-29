//
//  Runner.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation
import Combine

public enum RunnerError: Error {
    case network(error: Error)
    case decoder(error: Error)
}

public final class Runner {
    private let session = URLSession(configuration: .default)

    public func requestPublisher<T: Codable>(for request: URLRequest) -> AnyPublisher<T, RunnerError> {
        session.dataTaskPublisher(for: request)
            .mapError({ error in
                .network(error: error)
            })
            .flatMap({ response in
                self.requestDecoder(for: response.data)
            })
            .eraseToAnyPublisher()
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
                .decoder(error: error)
            })
            .eraseToAnyPublisher()
    }
}
