import AVFoundation
import os.log

private let ParserCallbacksLog = OSLog(subsystem: "me.foureyes.marconio", category: "parser")

// MARK: - AudioFileStreamOpen Callbacks

func ParserPropertyChangeCallback(_ context: UnsafeMutableRawPointer, _ streamID: AudioFileStreamID, _ propertyID: AudioFileStreamPropertyID, _ flags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {

    let parser = Unmanaged<Parser>.fromOpaque(context).takeUnretainedValue()

    /// Parse the various properties
    switch propertyID {
    case kAudioFileStreamProperty_DataFormat:
        var format = AudioStreamBasicDescription()
        GetPropertyValue(&format, streamID, propertyID)
        parser.dataFormat = AVAudioFormat(streamDescription: &format)
        os_log("Data format: %@", log: ParserCallbacksLog, type: .debug, String(describing: parser.dataFormat))

    case kAudioFileStreamProperty_AudioDataPacketCount:
        GetPropertyValue(&parser.packetCount, streamID, propertyID)
        os_log("Packet count: %i", log: ParserCallbacksLog, type: .debug, parser.packetCount)

    default:
        os_log("%@", log: ParserCallbacksLog, type: .debug, propertyID.description)
    }

}

func ParserPacketCallback(_ context: UnsafeMutableRawPointer, _ byteCount: UInt32, _ packetCount: UInt32, _ data: UnsafeRawPointer, _ packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>?) {
    let parser = Unmanaged<Parser>.fromOpaque(context).takeUnretainedValue()

    let isCompressed = packetDescriptions != nil

    guard let dataFormat = parser.dataFormat else {
        return
    }

    if isCompressed {
        guard let descriptions = packetDescriptions else {
            return
        }
        for i in 0 ..< Int(packetCount) {
            let packetDescription = descriptions[i]
            let packetStart = Int(packetDescription.mStartOffset)
            let packetSize = Int(packetDescription.mDataByteSize)
            let packetData = Data(bytes: data.advanced(by: packetStart), count: packetSize)
            parser.packets.append((packetData, packetDescription))
        }
    } else {
        let format = dataFormat.streamDescription.pointee
        let bytesPerPacket = Int(format.mBytesPerPacket)
        for i in 0 ..< Int(packetCount) {
            let packetStart = i * bytesPerPacket
            let packetSize = bytesPerPacket
            let packetData = Data(bytes: data.advanced(by: packetStart), count: packetSize)
            parser.packets.append((packetData, nil))
        }
    }
}

// MARK: - Utility
func GetPropertyValue<T>(_ value: inout T, _ streamID: AudioFileStreamID, _ propertyID: AudioFileStreamPropertyID) {
    var propSize: UInt32 = 0
    guard AudioFileStreamGetPropertyInfo(streamID, propertyID, &propSize, nil) == noErr else {
        os_log("Failed to get info for property: %@", log: ParserCallbacksLog, type: .error, String(describing: propertyID))
        return
    }

    guard AudioFileStreamGetProperty(streamID, propertyID, &propSize, &value) == noErr else {
        os_log("Failed to get value [%@]", log: ParserCallbacksLog, type: .error, String(describing: propertyID))
        return
    }
}

extension AudioFileStreamPropertyID {
    public var description: String {
        switch self {
        case kAudioFileStreamProperty_ReadyToProducePackets:
            return "Ready to produce packets"
        case kAudioFileStreamProperty_FileFormat:
            return "File format"
        case kAudioFileStreamProperty_DataFormat:
            return "Data format"
        case kAudioFileStreamProperty_AudioDataByteCount:
            return "Byte count"
        case kAudioFileStreamProperty_AudioDataPacketCount:
            return "Packet count"
        case kAudioFileStreamProperty_DataOffset:
            return "Data offset"
        case kAudioFileStreamProperty_BitRate:
            return "Bit rate"
        case kAudioFileStreamProperty_FormatList:
            return "Format list"
        case kAudioFileStreamProperty_MagicCookieData:
            return "Magic cookie"
        case kAudioFileStreamProperty_MaximumPacketSize:
            return "Max packet size"
        case kAudioFileStreamProperty_ChannelLayout:
            return "Channel layout"
        case kAudioFileStreamProperty_PacketToFrame:
            return "Packet to frame"
        case kAudioFileStreamProperty_FrameToPacket:
            return "Frame to packet"
        case kAudioFileStreamProperty_PacketToByte:
            return "Packet to byte"
        case kAudioFileStreamProperty_ByteToPacket:
            return "Byte to packet"
        case kAudioFileStreamProperty_PacketTableInfo:
            return "Packet table"
        case kAudioFileStreamProperty_PacketSizeUpperBound:
            return "Packet size upper bound"
        case kAudioFileStreamProperty_AverageBytesPerPacket:
            return "Average bytes per packet"
        case kAudioFileStreamProperty_InfoDictionary:
            return "Info dictionary"
        default:
            return "Unknown"
        }
    }
}
