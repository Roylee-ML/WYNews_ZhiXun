//
//  AVPlayerManger.m
//  StarProject
//
//  Created by Roy lee on 15/12/28.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "AVPlayerManger.h"
#import "Reachability.h"

NSString *kTracksKey		= @"tracks";
NSString *kPlayableKey		= @"playable";

static NSString *const kVideoPlayerItemReadyToPlay = @"kVideoPlayerItemReadyToPlay";
static NSString *const kVideoPlayerPlaybackBufferEmpty = @"kVideoPlayerPlaybackBufferEmpty";    // 无缓存播放暂停
static NSString *const kVideoPlayerPlaybackLikelyToKeepUp = @"kVideoPlayerPlaybackLikelyToKeepUp";

static const NSString *ItemStatusContext;

@interface AVPlayer (PlayerHandle)

- (void)seekToTimeInSeconds:(float)time completionHandler:(void (^)(BOOL finished))completionHandler;
- (NSTimeInterval)currentItemDuration;
- (NSTimeInterval)currentNSTime;
- (CMTime)currentCMTime;

@end


@interface AVPlayerView : UIView<AVPlayerViewDelegate>

@property (nonatomic, weak) AVPlayerManger * playerManger;

@end

@implementation AVPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor blackColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end


@interface AVPlayerManger ()

@property (nonatomic, strong) AVPlayer * avPlayer;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong,readwrite) AVPlayerView * playerView;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) NSTimeInterval beforeSeek;
@property (nonatomic, assign) NSTimeInterval previousPlaybackTime;
@property (nonatomic, assign) double currentBuffer;

@end

@implementation AVPlayerManger

void RUN_ON_UI_THREAD(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (instancetype)init
{
    if (self == [super init]) {
        [self addNotification];
        self.state = AVPlayerStateUnknown;
        self.beforeSeek = 0.0;
        self.previousPlaybackTime = 0;
        self.playerView = [[AVPlayerView alloc]initWithFrame:CGRectZero];
    }
    return self;
}

- (instancetype)initWithPlayerView:(UIView<AVPlayerViewDelegate>*)playerView
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    if (playerView) {
        [self.playerView setFrame:playerView.bounds];
        [playerView setPlayerManger:self];
        [self.playerView removeFromSuperview];
        [playerView addSubview:self.playerView];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeNotification];
    [self clearPlayer];
    [self.playerView setPlayerManger:nil];
    [self setPlayerView:nil];
}

- (void)clearPlayer
{
    [self.avPlayer pause];
    [self.avPlayer cancelPendingPrerolls];
    [self.avPlayer setRate:0.0f];
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    [self.playerView setPlayer:nil];
    
    self.avPlayer = nil;
    self.player = nil;
    self.playerItem = nil;
}

#pragma mark - Notif

- (void)addNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    [defaultCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
//    [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(playerItemReadyToPlay) name:kVideoPlayerItemReadyToPlay object:nil];
    
//    [defaultCenter addObserver:self forKeyPath:AVVideoQualityKey options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObserversWithItem:(AVPlayerItem *)item
{
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"timedMetadata"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:item];
}

- (void)setTimeObserver:(id)timeObserver {
    if (_timeObserver) {
        NSLog(@"TimeObserver: remove %@", _timeObserver);
        [self.avPlayer removeTimeObserver:_timeObserver];
    }
    _timeObserver = timeObserver;
    if (timeObserver) {
        NSLog(@"TimeObserver: setup %@", _timeObserver);
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"timedMetadata"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    _playerItem = playerItem;
    if (!playerItem) {
        return;
    }
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
}

- (void)setAvPlayer:(AVPlayer *)avPlayer {
    self.timeObserver = nil;
    [_avPlayer removeObserver:self forKeyPath:@"status"];
    _avPlayer = avPlayer;
    if (avPlayer) {
        __weak __typeof(self) weakSelf = self;
        [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        self.timeObserver = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
            [weakSelf periodicTimeObserver:time];
        }];
    }
}

#pragma mark - play
- (void)playVideoTrack:(id<AVPlayerTrackProtocol>)track
{
    [self clearPlayer];
    
    NSURL *streamURL = [track streamURL];
    if (!streamURL) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayer:willStartVideo:)]) {
        [_delegate videoPlayer:self willStartVideo:track];
        self.state = AVPlayerStateContentLoading;
    }
    [self playAVPlayer:streamURL playerLayerView:self.playerView track:track];
}

- (void)playAVPlayer:(NSURL*)streamURL playerLayerView:(id<AVPlayerViewDelegate>)playerLayerView track:(id<AVPlayerTrackProtocol>)track {
    
    if (!track.isVideoLoadedBefore) {
        track.isVideoLoadedBefore = YES;
    }
    
    NSAssert(self.playerView.superview, @"you must setup current playerview as a container view!");
        
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:streamURL options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    [asset loadValuesAsynchronouslyForKeys:@[kTracksKey, kPlayableKey] completionHandler:^{
        // Completion handler block.
        RUN_ON_UI_THREAD(^{
            if (![asset.URL.absoluteString isEqualToString:streamURL.absoluteString]) {
                NSLog(@"Ignore stream load success. Requested to load: %@ but the current stream should be %@.", asset.URL.absoluteString, streamURL.absoluteString);
                return;
            }
            NSError *error = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                self.avPlayer = [self playerWithPlayerItem:self.playerItem];
                self.player = (id<MangerPlayer>)self.avPlayer;
                [playerLayerView setPlayer:self.avPlayer];
                
            } else {
                // You should deal with the error appropriately.
                [self handleErrorCode:kVideoPlayerErrorAssetLoadError track:track];
                NSLog(@"The asset's tracks were not loaded:\n%@", error);
            }
        });
    }];  
}

- (AVPlayer*)playerWithPlayerItem:(AVPlayerItem*)playerItem {
    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    if ([player respondsToSelector:@selector(setAllowsAirPlayVideo:)]) player.allowsAirPlayVideo = NO;
    if ([player respondsToSelector:@selector(setAllowsExternalPlayback:)]) player.allowsExternalPlayback = NO;
    return player;
}


- (void)periodicTimeObserver:(CMTime)time {
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    NSTimeInterval lastTimeInSeconds = _previousPlaybackTime;
    
    if (timeInSeconds <= 0) {
        return;
    }
    
    if ([self isPlayingVideo]) {
        _previousPlaybackTime = timeInSeconds;
    }
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayFrame:time:lastTime:)]) {
        [self.delegate videoPlayer:self didPlayFrame:self.track time:timeInSeconds lastTime:lastTimeInSeconds];
    }
}

- (float)currentBitRateInKbps {
    return [self.playerItem.accessLog.events.lastObject observedBitrate]/1000;
}

#pragma mark - state
- (void)setState:(AVPlayerState)newPlayerState
{
    if (_state == newPlayerState) {
        return;
    }
    
    NSLog(@"Player State: %@ -> %@", [self playerStateDescription:self.state], [self playerStateDescription:newPlayerState]);
    
    switch (newPlayerState) {
        case AVPlayerStateUnknown:
            break;
            
        case AVPlayerStateContentLoading:
            break;
            
        case AVPlayerStateContentPlaying:
            [self.player play];
            break;
            
        case AVPlayerStateContentPaused:
            self.track.lastDurationWatchedInSeconds = [NSNumber numberWithFloat:[self currentTime]];
            [self.player pause];
            break;
            
        case AVPlayerStateSuspend:
            break;
            
        case AVPlayerStateError:
            [self.player pause];
            break;
    }
    
    _state = newPlayerState;
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayer:didChangeStateTo:)]) {
        [_delegate videoPlayer:self didChangeStateTo:newPlayerState];
    }
}

- (void)playerItemReadyToPlay {
    
    NSLog(@"Player: playerItemReadyToPlay");
    
    RUN_ON_UI_THREAD(^{
        switch (self.state) {
            case AVPlayerStateContentPaused:
                break;
            case AVPlayerStateContentLoading:{}
            case AVPlayerStateError:{
                [self pauseContentWithCompletionHandler:^{
                    if ([self.delegate respondsToSelector:@selector(videoPlayer:willStartVideo:)]) {
                        [self.delegate videoPlayer:self willStartVideo:self.track];
                    }
                    [self seekToLastWatchedDuration];
                }];
                break;
            }
            default:
                break;
        }
    });
}

- (void)playerDidPlayToEnd:(NSNotification *)notification {
    NSLog(@"Player: Did play to the end");
    RUN_ON_UI_THREAD(^{
        
        self.track.isPlayedToEnd = YES;
        [self pauseContentWithCompletionHandler:^{
            [self clearPlayer];
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayToEnd:)]) {
                [self.delegate videoPlayer:self didPlayToEnd:self.track];
            }
        }];
    });
}

- (void)handleErrorCode:(AVPlayerErrorCode)errorCode track:(id<AVPlayerTrackProtocol>)track {
    [self handleErrorCode:errorCode track:track customMessage:nil];
}

- (void)handleErrorCode:(AVPlayerErrorCode)errorCode track:(id<AVPlayerTrackProtocol>)track customMessage:(NSString*)customMessage {
    RUN_ON_UI_THREAD(^{
        if ([self.delegate respondsToSelector:@selector(handleErrorCode:track:customMessage:)]) {
            [self.delegate handleErrorCode:errorCode track:track customMessage:customMessage];
        }
    });
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.avPlayer) {
        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.avPlayer status]) {
                case AVPlayerStatusReadyToPlay:
                    NSLog(@"AVPlayerStatusReadyToPlay");
                    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                case AVPlayerStatusFailed:
                    NSLog(@"AVPlayerStatusFailed");
                    [self handleErrorCode:kVideoPlayerErrorAVPlayerFail track:self.track];
                default:
                    break;
            }
        }
    }
    
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if (self.playerItem.isPlaybackBufferEmpty && [self.delegate respondsToSelector:@selector(videoPlayer:isBuffering:)]) {
                [self.delegate videoPlayer:self isBuffering:YES];
            }
            
            NSLog(@"playbackBufferEmpty: %@", self.playerItem.isPlaybackBufferEmpty ? @"yes" : @"no");
            if (self.playerItem.isPlaybackBufferEmpty && [self currentTime] > 0 && [self currentTime] < [self.player currentItemDuration] - 1 && self.state == AVPlayerStateContentPlaying) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPlayerPlaybackBufferEmpty object:nil];
            }else if (!self.playerItem.isPlaybackBufferEmpty && [self currentTime] > 0 && [self currentTime] < [self.player currentItemDuration] - 1 && self.state == AVPlayerStateContentPlaying) {
                [self.player play];
            }
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.playerItem.playbackLikelyToKeepUp && [self.delegate respondsToSelector:@selector(videoPlayer:isBuffering:)]) {
                [self.delegate videoPlayer:self isBuffering:NO];
            }
            
            NSLog(@"playbackLikelyToKeepUp: %@", self.playerItem.playbackLikelyToKeepUp ? @"yes" : @"no");
            if (self.playerItem.playbackLikelyToKeepUp) {
                if (self.state == AVPlayerStateContentPlaying && ![self isPlayingVideo]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPlayerPlaybackLikelyToKeepUp object:nil];
                    [self.player play];
                }
            }
        }
        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.playerItem status]) {
                case AVPlayerItemStatusReadyToPlay:
                    NSLog(@"AVPlayerItemStatusReadyToPlay");
                    if ([self.avPlayer status] == AVPlayerStatusReadyToPlay) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"AVPlayerItemStatusFailed");
                    [self handleErrorCode:kVideoPlayerErrorAVPlayerItemFail track:self.track];
                default:
                    break;
            }
        }
        if([keyPath isEqualToString:@"loadedTimeRanges"]){
            NSArray *array = self.playerItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
            double startSeconds = CMTimeGetSeconds(timeRange.start);
            double durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
            NSLog(@"总时间：%.2f  共缓冲：%.2f",[self.player currentItemDuration],totalBuffer);
            _currentBuffer = totalBuffer;
            
            if (_delegate && [_delegate respondsToSelector:@selector(videoPlayer:didCurrentBuffer:totalBuffer:)]) {
                [_delegate videoPlayer:self didCurrentBuffer:totalBuffer totalBuffer:[self.player currentItemDuration]];
            }
        }
    }
}

#pragma mark - UIApplication Notify
- (void)applicationWillResignActive
{
    if ([self isPlayingVideo]) {
        [self pauseContent];
    }
}

- (void)applicationDidBecomeActive
{
    [self playContent];
}

#pragma mark - Public
#pragma mark - Function
- (void)setCurrentPlayerView:(UIView<AVPlayerViewDelegate>*)newPlayerView
{
    [self.playerView removeFromSuperview];
    if (!newPlayerView) {
        return;
    }
    [self.playerView setFrame:newPlayerView.bounds];
    [newPlayerView insertSubview:self.playerView atIndex:0];
    [newPlayerView setPlayerManger:self];
}

- (void)seekToLastWatchedDuration
{
    RUN_ON_UI_THREAD(^{
        
        CGFloat lastWatchedTime = [self.track.lastDurationWatchedInSeconds floatValue];
        if (lastWatchedTime > 5) lastWatchedTime -= 5;
        
        NSLog(@"Seeking to last watched duration: %f", lastWatchedTime);
        
        [self.player seekToTimeInSeconds:lastWatchedTime completionHandler:^(BOOL finished) {
            if (finished) [self playContent];
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didStartVideo:)]) {
                [self.delegate videoPlayer:self didStartVideo:self.track];
            }
        }];
    });
}

- (void)seekToTimeInSecond:(float)sec completionHandler:(void (^)(BOOL finished))completionHandler
{
    [self.player seekToTimeInSeconds:sec completionHandler:completionHandler];
}

- (BOOL)isPlayingVideo
{
    return (self.avPlayer && self.avPlayer.rate != 0.0);
}

- (NSTimeInterval)currentTime
{
    if (!self.track.isVideoLoadedBefore) {
        return [self.track.lastDurationWatchedInSeconds doubleValue] > 0 ? [self.track.lastDurationWatchedInSeconds doubleValue] : 0.0f;
    }
    return [self.player currentNSTime];
}

#pragma mark - Resource
- (void)loadVideoWithTrack:(id<AVPlayerTrackProtocol>)track
{
    self.track = track;
    self.state = AVPlayerStateContentLoading;
    
    void(^completionHandler)() = ^{
        [self playVideoTrack:self.track];
    };
    switch (self.state) {
        case AVPlayerStateError:
        case AVPlayerStateContentPaused:
        case AVPlayerStateContentLoading:
            completionHandler();
            break;
        case AVPlayerStateContentPlaying:
            [self pauseContentWithCompletionHandler:completionHandler];
            break;
        default:
            break;
    };
}

- (void)loadVideoWithStreamURL:(NSURL*)streamURL
{
    [self loadVideoWithTrack:[[AVPlayerTrack alloc] initWithStreamURL:streamURL]];
}

// reload the track,it's will replay from start time.
- (void)reloadCurrentVideoTrack {
    RUN_ON_UI_THREAD(^{
        void(^completionHandler)() = ^{
            self.state = AVPlayerStateContentLoading;
            [self loadCurrentVideoTrack];
        };
        
        switch (self.state) {
            case AVPlayerStateUnknown:
            case AVPlayerStateContentLoading:
            case AVPlayerStateContentPaused:
            case AVPlayerStateError:
                NSLog(@"Reload stream now.");
                completionHandler();
                break;
            case AVPlayerStateContentPlaying:
                NSLog(@"Reload stream after pause.");
                [self pauseContentWithCompletionHandler:completionHandler];
                break;
            case AVPlayerStateSuspend:
                break;
        }
    });
}

- (void)loadCurrentVideoTrack {
    __weak __typeof__(self) weakSelf = self;
    RUN_ON_UI_THREAD(^{
        [weakSelf playVideoTrack:self.track];
    });
}

- (void)setTrack:(id<AVPlayerTrackProtocol>)track {
    if (_track == track) {
        return;
    }
    _track = track;
    [self clearPlayer];
}

#pragma mark - Controls
- (void)playContent {
    RUN_ON_UI_THREAD(^{
        if (self.state == AVPlayerStateContentPaused) {
            self.state = AVPlayerStateContentPlaying;
        }
    });
}

- (void)pauseContent {
    [self pauseContentWithCompletionHandler:nil];
}

- (void)pauseContentWithCompletionHandler:(void (^)())completionHandler {
    RUN_ON_UI_THREAD(^{
        
        switch ([self.playerItem status])
        {
            case AVPlayerItemStatusFailed:
                self.state = AVPlayerStateError;
                NSLog(@"state item error");
                return;
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"Trying to pause content but AVPlayerItemStatusUnknown.");
                self.state = AVPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch ([self.avPlayer status])
        {
            case AVPlayerStatusFailed:
                NSLog(@"state error");
                self.state = AVPlayerStateError;
                return;
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"Trying to pause content but AVPlayerStatusUnknown.");
                self.state = AVPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch (self.state)
        {
            case AVPlayerStateContentLoading:
            case AVPlayerStateContentPlaying:
            case AVPlayerStateContentPaused:
            case AVPlayerStateSuspend:
            case AVPlayerStateError:
                self.state = AVPlayerStateContentPaused;
                if (completionHandler) completionHandler();
                break;
            default:
                break;
        }
    });
}


- (NSString*)playerStateDescription:(AVPlayerState)playerState {
    switch (playerState) {
        case AVPlayerStateUnknown:
            return @"Unknown";
            break;
        case AVPlayerStateContentLoading:
            return @"ContentLoading";
            break;
        case AVPlayerStateContentPaused:
            return @"ContentPaused";
            break;
        case AVPlayerStateContentPlaying:
            return @"ContentPlaying";
            break;
        case AVPlayerStateSuspend:
            return @"Player Stay";
            break;
        case AVPlayerStateError:
            return @"Player Error";
            break;
    }
}

@end




@implementation AVPlayer (PlayerHandle)

- (void)seekToTimeInSeconds:(float)time completionHandler:(void (^)(BOOL finished))completionHandler {
    if ([self respondsToSelector:@selector(seekToTime:toleranceBefore:toleranceAfter:completionHandler:)]) {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
    } else {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        completionHandler(YES);
    }
}

- (NSTimeInterval)currentItemDuration {
    return CMTimeGetSeconds([self.currentItem duration]);
}

- (NSTimeInterval)currentNSTime {
    return CMTimeGetSeconds([self currentTime]);
}

- (CMTime)currentCMTime {
    return [self currentTime];
}

@end