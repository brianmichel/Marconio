//
//  PlaybackClient.swift
//  
//
//  Created by Brian Michel on 6/12/22.
//
import AVFoundation
import ComposableArchitecture
import Combine

public struct PlaybackClient {
    var play: (URL) -> Effect<Action, Never>
    var resume: () -> Effect<Action, Never>
    var pause: () -> Effect<Action, Never>
    var stop: () -> Effect<Action, Never>

    var retreiveRoutes: () -> Effect<Action, Never>

    public enum Action: Equatable {
        case receivedRoutes(RoutePickerView?)
    }
}

public extension PlaybackClient {
    static var live: Self {
        var delegate: PlaybackClientDelegate?

        return .init(
            play: { url in
                .future { callback in
                    delegate = PlaybackClientDelegate()

                    delegate?.load(url: url)
                    delegate?.resume()
                }
        },
            resume: {
                .fireAndForget({
                    delegate?.resume()
                })
            },
            pause: {
                .fireAndForget({
                    delegate?.pause()
                })
        },
            stop: {
                .fireAndForget({
                    delegate?.stop()
                    delegate = nil
                })
            },
            retreiveRoutes: {
                .run { subscriber in
                    subscriber.send(.receivedRoutes(delegate?.routeView))

                    return AnyCancellable {}
                }
            }
        )
    }

    static var noop: Self {
        return .init(play: { _ in .none },
                     resume: { .none },
                     pause: { .none },
                     stop: { .none },
                     retreiveRoutes: { .none })
    }
}

private var playerItemContext = 0

private final class PlaybackClientDelegate: NSObject {
    private var player: AVPlayer?

    private var storage = Set<AnyCancellable>()

    var routeView: RoutePickerView? {
        guard let activePlayer = player else { return nil }
        #if os(macOS)
        return RoutePickerView(routePickerButtonBordered: false, player: activePlayer)
        #else
        return RoutePickerView(player: activePlayer)
        #endif
    }

    func load(url: URL) {
        let asset = AVAsset(url: url)

        let requiredAssetKeys = [
            "playable",
            "hasProtectedContent"
        ]

        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)

        let player = AVPlayer(playerItem: item)
        player.allowsExternalPlayback = true

        self.player = player

        setupObservation(for: item)
    }

    func resume() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
    }

    // MARK: - Observation
    private func setupObservation(for item: AVPlayerItem) {
        print("Setting Up Observations")
        item.publisher(for: \.status, options: .new)
            .sink { [weak self] status in
                switch status {
                case .failed:
                    print("Failed: \(String(describing: self?.player?.error))")
                case .readyToPlay:
                    print("ready to play!")
                case .unknown:
                    print("unknown")
                @unknown default:
                    fatalError("Received unknown player status: \(status)")
                }
            }
            .store(in: &storage)
    }

    deinit {
        stop()
    }
}

extension PlaybackClient: DependencyKey {
    public static var liveValue: PlaybackClient = .live
}

extension DependencyValues {
    var player: PlaybackClient {
        get { self[PlaybackClient.self] }
        set { self[PlaybackClient.self] = newValue }
    }
}
