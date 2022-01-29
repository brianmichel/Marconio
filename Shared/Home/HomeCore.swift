//
//  HomeCore.swift
//  Lace (iOS)
//
//  Created by Brian Michel on 1/27/22.
//

import Combine
import Foundation
import LaceKit

final class HomeCore: ObservableObject {
    @Published private(set) var channels: [Channel] = []
    @Published private(set) var mixtapes: [Mixtape] = []
    private let api = LiveAPI()

    private var cancellables = Set<AnyCancellable>()

    init() {
        update()
    }

    func update() {
        try! Publishers
            .Zip(api.live(), api.mixtapes())
            .receive(on: DispatchQueue.main, options: .none)
            .sink(receiveCompletion: { result in
                print("result: \(result)")
            }, receiveValue: { [weak self] channels, mixtapes in
                self?.channels = channels.results
                self?.mixtapes = mixtapes.results
            }).store(in: &cancellables)
    }
}
