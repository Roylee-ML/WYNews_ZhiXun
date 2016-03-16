//
//  AVPlayerTrack.h
//  StarProject
//
//  Created by Roy lee on 15/12/28.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVPlayerTrackProtocol <NSObject>

@property (nonatomic, assign) BOOL isPlayedToEnd;
@property (nonatomic, assign) BOOL isVideoLoadedBefore;
@property (nonatomic, strong) NSIndexPath *itemIndexPath;
@property (nonatomic, strong) NSNumber* totalVideoDuration;
@property (nonatomic, strong) NSNumber* lastDurationWatchedInSeconds;

// video title
- (NSString*)title;

// video stream URL
- (NSURL*)streamURL;

- (BOOL)hasNext;
- (BOOL)hasPrevious;

@end

/**
 *   播放资源的信息
 */
@interface AVPlayerTrack : NSObject<AVPlayerTrackProtocol>
{
    BOOL _isVideoLoadedBefore;
    NSNumber* _totalVideoDuration;
    NSNumber* _lastDurationWatchedInSeconds;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSIndexPath *itemIndexPath;
@property (nonatomic, assign) BOOL hasNext;
@property (nonatomic, assign) BOOL hasPrevious;
@property (nonatomic, assign) BOOL isPlayedToEnd;
@property (nonatomic, strong) NSURL* streamURL;
@property (nonatomic, assign) BOOL isVideoLoadedBefore;
@property (nonatomic, strong) NSNumber* totalVideoDuration;
@property (nonatomic, strong) NSNumber* lastDurationWatchedInSeconds;

- (id)initWithStreamURL:(NSURL*)url;

@end



