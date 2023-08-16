import AVFAudio
import Combine
import Foundation

public final class StreamingAudioPlayer: NSObject {
    private let downloadQueue = OperationQueue()
    private let parser: Parser
    lazy var session: URLSession = {
        return URLSession(configuration: .default)
    }()

    public init(type: AudioFileTypeID) throws {
        parser = try Parser(type: type)
    }

    public func load(url: URL) async {
        // (1) Start Download
        // ↳ (2) Parse Data Into Audio Packets (data -> audio packets written to buffer)
        //  ↳ (3) Reader Reads Audio Packets To Be Played (buffer reading)
        //   ↳ (4) Player Schedules Buffer Into Audio Node (audio rendering)
        // queue linear pcm data
        do {
            for try await data in stream(for: url) {
                print("got data! \(data)")
                try parser.parse(data: data)
                
            }
        } catch let error {
            // do nothing yet...
            print("Error: \(error)")
        }
    }

    private func stream(for url: URL) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let delegate = URLSessionDataDelegatePublisher(continuation: continuation)

            Task {
                do {
                    let (bytes, _) = try await session.bytes(from: url, delegate: delegate)
                    // Setup our temporary buffer
                    let limit = 4096
                    var data = Data(capacity: limit)
                    for try await byte in bytes {
                        data.append(byte)
                        if data.count == limit {
                            continuation.yield(data)
                            data.removeAll(keepingCapacity: true)
                        }
                    }

                } catch let error {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

extension StreamingAudioPlayer: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // (2) parse the raw data into audio packets
    }
}

final class URLSessionDataDelegatePublisher: NSObject, URLSessionDataDelegate {
    let continuation: AsyncThrowingStream<Data, Error>.Continuation

    init(continuation: AsyncThrowingStream<Data, Error>.Continuation) {
        self.continuation = continuation
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        continuation.yield(data)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        continuation.finish(throwing: error)
    }

    deinit {
        print("Bye Bye!")
    }
}

