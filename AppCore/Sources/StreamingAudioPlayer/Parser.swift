import AVFoundation
import os.log

enum ParserError: Error  {
    case streamCouldNotOpen
    case failedToParseBytes(OSStatus)
}

final class Parser {
    public internal(set) var dataFormat: AVAudioFormat?
    public internal(set) var packets = [(Data, AudioStreamPacketDescription?)]()

    /// A `UInt64` corresponding to the total frame count parsed by the Audio File Stream Services
    public internal(set) var frameCount: UInt64 = 0

    /// A `UInt64` corresponding to the total packet count parsed by the Audio File Stream Services
    public internal(set) var packetCount: UInt64 = 0

    /// The `AudioFileStreamID` used by the Audio File Stream Services for converting the binary data into audio packets
    fileprivate var streamID: AudioFileStreamID?

    public var totalPacketCount: AVAudioPacketCount? {
        guard let _ = dataFormat else {
            return nil
        }

        return max(AVAudioPacketCount(packetCount), AVAudioPacketCount(packets.count))
    }

    public init(type: AudioFileTypeID = kAudioFileMP3Type) throws {
        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)

        guard AudioFileStreamOpen(context, ParserPropertyChangeCallback, ParserPacketCallback, type, &streamID) == noErr else {
            throw ParserError.streamCouldNotOpen
        }
    }

    func parse(data: Data) throws {
        let streamID = self.streamID!
        let count = data.count
        try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            let result = AudioFileStreamParseBytes(streamID, UInt32(count), bytes, [])
            guard result == noErr else {
                throw ParserError.failedToParseBytes(result)
            }
        }
    }
}
