//
//  VideoViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NewsAPIUrl.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "OnePlayer.h"

typedef NS_ENUM(NSInteger, PlayWindowStyle) {
    PlayWindowSmall,
    PlayWindowOrgin
};

WY_DEPRECATED_IOS(2_2, "VideoViewController has been replaced with VideoPlayControler")

@interface VideoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FinishedPlay,ShowPlayingAudio>

@end
