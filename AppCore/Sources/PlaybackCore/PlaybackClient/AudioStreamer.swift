import AVFoundation
import Combine
import CoreMedia
import MediaToolbox
import AudioTap

public final class AudioStreamer: NSObject, AudioTapDelegate {
    private var player: AVPlayer?
    private var tap: AudioTap?

    private var storage = Set<AnyCancellable>()

    @Published var playbackStatus: AVPlayerItem.Status = .unknown

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
            "tracks"
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
        item.publisher(for: \.status, options: .new)
            .sink { [weak self] status in
                self?.playbackStatus = status
            }
            .store(in: &storage)

        item.publisher(for: \.tracks, options: .new)
            .sink { [weak self] tracks in
                guard
                    let firstAudioTrack = tracks.first(where: { $0.assetTrack?.mediaType == .audio }),
                    let assetTrack = firstAudioTrack.assetTrack,
                    self?.tap == nil else {
                    // no sound/audio track yet, bail
                    return
                }
                self?.setupTap(for: assetTrack)
            }
            .store(in: &storage)

        item.publisher(for: \.error, options: .new)
            .sink { error in
                guard let error else { return }
                print("Item error: \(error.localizedDescription)")
            }
            .store(in: &storage)
    }

    private func setupTap(for track: AVAssetTrack)  {
        // Clear up the old tap
        guard let player = self.player else { return }
        self.tap = nil

        self.tap = AudioTap(track, player: player)
        self.tap?.delegate = self
    }

    // MARK: - AudioTapDelegate
    public func tap(_ tap: AudioTap, didReceiveError error: Error) {
        // Do something
    }

    public func tap(_ tap: AudioTap, didProcessBuffer buffer: AVAudioPCMBuffer) {
        // Do something
    }

    deinit {
        stop()
    }
}


