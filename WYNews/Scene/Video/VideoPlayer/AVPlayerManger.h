//
//  AVPlayerManger.h
//  StarProject
//
//  Created by Roy lee on 15/12/28.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPlayerTrack.h"

static NSString *const kVideoPlayerItemReadyToPlay;
static NSString *const kVideoPlayerPlaybackBufferEmpty;
static NSString *const kVideoPlayerPlaybackLikelyToKeepUp;

typedef NS_ENUM(NSInteger, AVPlayerErrorCode) {
    // The video was flagged as blocked due to licensing restrictions (geo or device).
    kVideoPlayerErrorVideoBlocked = 900,
    
    // There was an error fetching the stream.
    kVideoPlayerErrorFetchStreamError,
    
    // Could not find the stream type for video.
    kVideoPlayerErrorStreamNotFound,
    
    // There was an error loading the video as an asset.
    kVideoPlayerErrorAssetLoadError,
    
    // There was an error loading the video's duration.
    kVideoPlayerErrorDurationLoadError,
    
    // AVPlayer failed to load the asset.
    kVideoPlayerErrorAVPlayerFail,
    
    // AVPlayerItem failed to load the asset.
    kVideoPlayerErrorAVPlayerItemFail,
    
    // Chromecast failed to load the stream.
    kVideoPlayerErrorChromecastLoadFail,
    
    // There was an unknown error.
    kVideoPlayerErrorUnknown,
    
};


typedef NS_ENUM(NSInteger, AVPlayerState) {
    AVPlayerStateUnknown,
    AVPlayerStateContentLoading,
    AVPlayerStateContentPlaying,
    AVPlayerStateContentPaused,
    AVPlayerStateSuspend,
    AVPlayerStateError
};

@class AVPlayerManger;
@protocol AVPlayerViewDelegate <NSObject>
@property (nonatomic, weak) AVPlayerManger * playerManger;

- (void)setPlayer:(AVPlayer *)player;

@end



@protocol MangerPlayer <NSObject>
- (void)play;
- (void)pause;
- (NSTimeInterval)currentNSTime;
- (CMTime)currentCMTime;
- (NSTimeInterval)currentItemDuration;
- (void)seekToTimeInSeconds:(float)time completionHandler:(void (^)(BOOL finished))completionHandler;

@end



@protocol AVPlayerDelegate <NSObject>
@optional
- (void)videoPlayer:(AVPlayerManger*)playerManger didChangeStateTo:(AVPlayerState)fromState;

- (void)videoPlayer:(AVPlayerManger*)playerManger willStartVideo:(id<AVPlayerTrackProtocol>)track;
- (void)videoPlayer:(AVPlayerManger*)playerManger didStartVideo:(id<AVPlayerTrackProtocol>)track;

- (void)videoPlayer:(AVPlayerManger *)playerManger isBuffering:(BOOL)buffering;
- (void)videoPlayer:(AVPlayerManger *)playerManger didCurrentBuffer:(double)currentBf totalBuffer:(double)totalBf;

- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayFrame:(id<AVPlayerTrackProtocol>)track time:(NSTimeInterval)time lastTime:(NSTimeInterval)lastTime;
- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayToEnd:(id<AVPlayerTrackProtocol>)track;

- (void)handleErrorCode:(AVPlayerErrorCode)errorCode track:(id<AVPlayerTrackProtocol>)track customMessage:(NSString*)customMessage;

@end


@interface AVPlayerManger : NSObject

@property (nonatomic, strong, readonly) UIView<AVPlayerViewDelegate>*playerView;
@property (nonatomic, strong) id<MangerPlayer>player;
@property (nonatomic, strong) id<AVPlayerTrackProtocol> track;
@property (nonatomic, assign) id<AVPlayerDelegate> delegate;
@property (nonatomic, assign) AVPlayerState state;
@property (nonatomic, assign) BOOL isFullScreenMode;

- (instancetype)initWithPlayerView:(UIView *)playerView;

#pragma mark - Function
/* by default the playerview's superview will insert it at index:0 */
- (void)setCurrentPlayerView:(UIView *)newPlayerView;

- (void)seekToLastWatchedDuration;
- (void)seekToTimeInSecond:(float)sec completionHandler:(void (^)(BOOL finished))completionHandler;
- (BOOL)isPlayingVideo;
- (NSTimeInterval)currentTime;
- (float)currentBitRateInKbps;

#pragma mark - Resource
- (void)loadVideoWithTrack:(id<AVPlayerTrackProtocol>)track;
- (void)loadVideoWithStreamURL:(NSURL*)streamURL;
- (void)reloadCurrentVideoTrack;
- (void)clearPlayer;

#pragma mark - Controls
- (void)playContent;
- (void)pauseContent;
- (void)pauseContentWithCompletionHandler:(void (^)())completionHandler;

@end
