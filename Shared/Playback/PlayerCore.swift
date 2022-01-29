//
//  PlayerCore.swift
//  Lace
//
//  Created by Brian Michel on 1/28/22.
//

import AVFoundation
import Foundation
import LaceKit
import MediaPlayer
import ComposableArchitecture


struct PlaybackState: Equatable {
    enum PlayerState: Equatable {
        case playing, paused, stopped
    }

    var currentlyPlaying: MediaPlayable?
    var playerState: PlayerState = .stopped
}

enum PlaybackAction: Equatable {
    case loadPlayable(MediaPlayable)
    case pausePlayback
    case resumePlayback
    case stopPlayback
}

struct PlaybackEnvironment {
    // An intersting side effect of using TCA seems like you need to have these kind of persistent resources static
    // Maybe I'm just using it wrong?
    static var player: AVPlayer = AVPlayer()
}

let playbackReducer = Reducer<PlaybackState, PlaybackAction, PlaybackEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {
        case let .loadPlayable(playable):
            let item = AVPlayerItem(url: playable.streamURL)
            PlaybackEnvironment.player.pause()
            PlaybackEnvironment.player.replaceCurrentItem(with: item)
            PlaybackEnvironment.player.play()
            state.playerState = .playing

            state.currentlyPlaying = playable
            return .none
        case .pausePlayback:
            PlaybackEnvironment.player.pause()
            state.playerState = .paused
            return .none
        case .resumePlayback:
            PlaybackEnvironment.player.play()
            state.playerState = .playing
            return .none
        case .stopPlayback:
            state.playerState = .stopped
            state.currentlyPlaying = nil
            PlaybackEnvironment.player.pause()
            PlaybackEnvironment.player.replaceCurrentItem(with: nil)
            return .none
        }
    }
)

struct MediaPlayable: Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String?
    var description: String
    var artwork: URL
    var streamURL: URL
}

extension MediaPlayable {
    init(mixtape: Mixtape) {
        id = mixtape.id
        title = mixtape.title
        subtitle = nil
        description = mixtape.description
        artwork = mixtape.media.pictureLarge
        streamURL = mixtape.audioStreamEndpoint
    }

    init(channel: Channel) {
        id = channel.id
        title = "Channel \(channel.channelName)"
        description = "Description not provided by NTS or broadcaster."

        if let programDescription = channel.now.details?.description, !programDescription.isEmpty {
            description = programDescription
        }

        subtitle = channel.now.broadcastTitle

        artwork = channel.now.details?.media.backgroundLarge ?? URL(fileURLWithPath: "file://")

        var components = URLComponents()
        components.scheme = "https"
        components.host = "stream-relay-geo.ntslive.net"

        switch channel.channelName {
        case "1":
            components.path = "/stream"
        case "2":
            components.path = "/stream2"
        default:
            print("Unknown stream channel has been provided, returning a stream URL that will not stream")
        }

        streamURL = components.url!
    }
}
