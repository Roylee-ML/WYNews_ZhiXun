//
//  VideoStatusLayout.h
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>

// 视频播放状态
typedef NS_ENUM(NSInteger, VideoPlayStatus) {
    VideoPlayStatusNormal,
    VideoPlayStatusBeginPlay,
    VideoPlayStatusPlaying,
    VideoPlayStatusPause,
    VideoPlayStatusEndPlay,
    VideoPlayStatusFailedPlay
};

@interface VideoStatusLayout : NSObject

@property (nonatomic, assign) VideoPlayStatus playStatus;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat buffer;
@property (nonatomic, assign) double totalTime;
@property (nonatomic, assign) double currentTime;

@end
