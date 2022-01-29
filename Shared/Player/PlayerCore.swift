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

protocol MediaPlayable {
    var streamURL: URL { get }
    var title: String { get }
    var subtitle: String? { get }
    var description: String { get }
    var artwork: URL { get }
}

final class PlayerCore {
    let playable: MediaPlayable
    lazy var player: AVPlayer = {
        let item = AVPlayerItem(url: playable.streamURL)
        let player = AVPlayer(playerItem: item)

        return player
    }()

    init(playable: MediaPlayable) {
        self.playable = playable

        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }


        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }
    }

    // MARK: Playback
    func play() {
        MPNowPlayingInfoCenter.default().playbackState = .playing
        player.play()
        updateNowPlaying(playable: playable)
    }

    func stop() {
        MPNowPlayingInfoCenter.default().playbackState = .paused
        player.pause()
    }

    deinit {
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        MPRemoteCommandCenter.shared().playCommand.removeTarget(self)
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(self)
        player.pause()
        updateNowPlaying(playable: nil)
    }

    private func updateNowPlaying(playable: MediaPlayable?) {
        let center = MPNowPlayingInfoCenter.default()

        guard let actualPlayable = playable else {
            center.nowPlayingInfo = nil
            return
        }
        center.nowPlayingInfo = [
            MPMediaItemPropertyTitle: actualPlayable.title,
            MPMediaItemPropertyArtist: actualPlayable.subtitle ?? "NTS",
            MPMediaItemPropertyMediaType: MPMediaType.anyAudio.rawValue,
            MPNowPlayingInfoPropertyIsLiveStream: NSNumber(integerLiteral: 1)
        ]
        
    }
}

extension Mixtape: MediaPlayable {
    var subtitle: String? {
        return nil
    }

    var streamURL: URL {
        return audioStreamEndpoint
    }

    var artwork: URL {
        return media.pictureLarge
    }
}

extension Channel: MediaPlayable {
    var subtitle: String? {
        return now.broadcastTitle
    }

    var streamURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "stream-relay-geo.ntslive.net"

        switch channelName {
        case "1":
            components.path = "/stream"
        case "2":
            components.path = "/stream2"
        default:
            print("Unknown stream channel has been provided, returning a stream URL that will not stream")
        }

        return components.url!
    }

    var title: String {
        return "Channel \(channelName)"
    }

    var description: String {
        if let description = now.details?.description, !description.isEmpty {
            return description
        }

        return "Description not provided by NTS or broadcaster."
    }

    var artwork: URL {
        return now.details?.media.backgroundLarge ?? URL(fileURLWithPath: "file://")
    }


}
