#import "AudioTap.h"

@interface AudioTap ()
@property (nonatomic, nullable) AudioStreamBasicDescription const *audioDescription;
@property (nonatomic, nullable) MTAudioProcessingTapRef tapReference;
@property (nonatomic, weak) AVPlayer *audioPlayer;
@end

@implementation AudioTap

// MARK: - MTAudioProcessingTapCallbacks Definitions

// Setting up storage for the downstream processing of the audio information.
void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut) {
    NSLog(@"Initializing...");
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap) {
    NSLog(@"Finalizing...");
}

// Use the prepare call to store the audio description so that we can use it later.
void prepare(MTAudioProcessingTapRef tap,
             CMItemCount maxFrames,
             const AudioStreamBasicDescription *processingFormat) {
    NSLog(@"Preparing...");
    AudioTap *audioTap = (__bridge AudioTap *) MTAudioProcessingTapGetStorage(tap);

    [audioTap callbackUpdateDescription:processingFormat];
}

void unprepare(MTAudioProcessingTapRef tap) {
    NSLog(@"Unpreparing...");
}

void process(MTAudioProcessingTapRef tap,
             CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags,
             AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut,
             MTAudioProcessingTapFlags *flagsOut) {
    NSLog(@"Processing...");
    AudioTap *audioTap = (__bridge AudioTap *) MTAudioProcessingTapGetStorage(tap);

    OSStatus error = MTAudioProcessingTapGetSourceAudio(tap,
                                                        numberFrames,
                                                        bufferListInOut,
                                                        flagsOut,
                                                        NULL,
                                                        numberFramesOut);

    if(error) {
        NSError *delegateError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
        [audioTap callbackReceivedError:delegateError];
        return;
    }

    [audioTap callbackRecievedBufferList:bufferListInOut];
}

- (instancetype)init:(nullable AVAssetTrack *)track player:(AVPlayer *)player {
    self = [super init];
    if (self) {
        MTAudioProcessingTapRef tap;
        MTAudioProcessingTapCallbacks callbacks;
        callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
        callbacks.clientInfo = (__bridge void *)(self);
        callbacks.init = init;
        callbacks.prepare = prepare;
        callbacks.process = process;
        callbacks.unprepare = unprepare;
        callbacks.finalize = finalize;

        OSStatus error = MTAudioProcessingTapCreate(kCFAllocatorDefault,
                                                    &callbacks,
                                                    kMTAudioProcessingTapCreationFlag_PreEffects,
                                                    &tap);

        if (error) {
            NSError *delegateError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
            NSLog(@"Error setting up tap: %@", [delegateError localizedDescription]);
            return nil;
        }

        // Create an AudioMix and assign it to our currently playing "item", which
        // is just the stream itself.
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters
                                                        audioMixInputParametersWithTrack:track];

        parameters.audioTapProcessor = tap;
        audioMix.inputParameters = @[parameters];

        player.currentItem.audioMix = audioMix;

        self.tapReference = tap;
        self.audioPlayer = player;
    }

    return self;
}

// MARK: - AudioTapDelegate Methods

- (void)callbackUpdateDescription:(const AudioStreamBasicDescription *)description {
    self.audioDescription = description;
}

- (void)callbackRecievedBufferList:(AudioBufferList *)list {
    if (self.audioDescription == nil) { return; }

    AVAudioFormat *format = [[AVAudioFormat alloc] initWithStreamDescription:self.audioDescription];
    if (!format) { return; }

    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                                          bufferListNoCopy:list
                                                               deallocator:^(const AudioBufferList * _Nonnull value) {
        CFRelease(value);
    }];
    if (!buffer) { return; }

    [self.delegate tap:self didProcessBuffer:buffer];
}

- (void)callbackReceivedError:(NSError *)error {
    [self.delegate tap:self didReceiveError:error];
}

- (void)dealloc {
    if (self.tapReference != nil) {
        CFRelease(self.tapReference);
        self.tapReference = nil;
    }
}

@end
