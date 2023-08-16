//
//  PlaybackClient.swift
//  
//
//  Created by Brian Michel on 6/12/22.
//
import AVFoundation
import ComposableArchitecture
import Combine
import StreamingAudioPlayer

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
        var streamer: AudioStreamer?
        var streaming: StreamingAudioPlayer?

        return .init(
            play: { url in
                .future { callback in
                    streamer = AudioStreamer()
                    streaming = try? StreamingAudioPlayer(type: kAudioFileMP3Type)

                    streamer?.load(url: url)
                    streamer?.resume()

                    Task.detached { [stream = streaming] in
                        await stream?.load(url: url)
                    }
                }
            },
            resume: {
                .fireAndForget({
                    streamer?.resume()
                })
            },
            pause: {
                .fireAndForget({
                    streamer?.pause()
                })
            },
            stop: {
                .fireAndForget({
                    streamer?.stop()
                    streamer = nil
                })
            },
            retreiveRoutes: {
                .run { subscriber in
                    subscriber.send(.receivedRoutes(streamer?.routeView))

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

extension PlaybackClient: DependencyKey {
    public static var liveValue: PlaybackClient = .live
}

extension DependencyValues {
    var player: PlaybackClient {
        get { self[PlaybackClient.self] }
        set { self[PlaybackClient.self] = newValue }
    }
}
