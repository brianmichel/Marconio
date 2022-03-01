//
//  Live.swift
//  
//
//  Created by Brian Michel on 2/28/22.
//

import Foundation
import Combine
import ComposableArchitecture
import AVFoundation
import Models

public extension AudioPlayerClient {
    static var live: Self {
        var delegate: AudioPlayerClientDelegate?
        
        return Self(
            load: { playable in
                    .run { subscriber in
                        delegate?.player.pause()
                        let newDelegate = AudioPlayerClientDelegate(url: playable.streamURL)
                        newDelegate.player.play()

                        print("Returning player: \(newDelegate)")
                        delegate = newDelegate
                        subscriber.send(.didLoad(newDelegate.player))

                        return AnyCancellable {}
                    }
            },
            play: {
                .fireAndForget {
                    delegate?.player.play()
                }
            },
            pause: {
                .fireAndForget {
                    print("[DEBUG] delegate is: \(delegate)")
                    delegate?.player.pause()
                }
            },
            stop: {
                .fireAndForget {
                    delegate?.player.pause()
                    delegate?.player.replaceCurrentItem(with: nil)
//                    delegate = nil
                }
            })
    }
}

public class AudioPlayerClientDelegate: NSObject {
    let player: AVPlayer

    init(url: URL) {
        print("[DEBUG] initializing a new player for url: \(url)")
        player = AVPlayer(url: url)
    }
}
