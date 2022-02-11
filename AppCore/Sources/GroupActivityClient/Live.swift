//
//  Live.swift
//  
//
//  Created by Brian Michel on 2/10/22.
//

import Combine
import ComposableArchitecture
import Foundation

public extension GroupActivityClient {
    static var live: Self {
        return Self(
            advertise: {
            .run { subscriber in
                Task {
                    do {
                        _ = try await ListenTogether().activate()
                        subscriber.send(.didStartAdvertising)
                    } catch {
                        subscriber.send(completion: .failure(.unableToActivate))
                    }
                }

                return AnyCancellable {}
            }
            },
            listen: {
            .run { subscriber in
                Task {
                    for await session in ListenTogether.sessions() {
                        subscriber.send(.configureSession(session))
                    }
                }

                return AnyCancellable {}
            }
        })
    }
}
