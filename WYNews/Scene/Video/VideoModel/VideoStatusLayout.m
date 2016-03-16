//
//  VideoStatusLayout.m
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "VideoStatusLayout.h"

@implementation VideoStatusLayout

- (instancetype)init
{
    if (self == [super init]) {
        _playStatus = VideoPlayStatusNormal;
        _progress = 0.0f;
        _totalTime = 0.0f;
        _currentTime = 0.0f;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [self autoEncodeWithCoder:aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init]) {
        [self autoDecode:aDecoder];
    }
    return self;
}

@end
