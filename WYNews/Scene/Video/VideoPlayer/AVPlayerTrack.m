//
//  AVPlayerTrack.m
//  StarProject
//
//  Created by Roy lee on 15/12/28.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "AVPlayerTrack.h"

@implementation AVPlayerTrack

- (id)initWithStreamURL:(NSURL*)url {
    self = [super init];
    if (self) {
        self.streamURL = url;
    }
    return self;
}

@end
