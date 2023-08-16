#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AudioTap;
@protocol AudioTapDelegate
- (void)tap:(AudioTap *)tap didProcessBuffer:(AVAudioPCMBuffer *)buffer;
- (void)tap:(AudioTap *)tap didReceiveError:(NSError *)error;
@end

@interface AudioTap: NSObject

@property (weak, nullable) id<AudioTapDelegate> delegate;

- (instancetype)init:(nullable AVAssetTrack *)track player:(AVPlayer *)player;

@end

NS_ASSUME_NONNULL_END
