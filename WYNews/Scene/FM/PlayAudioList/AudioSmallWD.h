//
//  AudioSmallWD.h
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMPlayingModel.h"

@interface AudioSmallWD : UIWindow

@property (nonatomic,strong) UIImageView * playImgView;
@property (nonatomic,strong) UIProgressView * progress;
@property (nonatomic,strong) UILabel * titleLable;
@property (nonatomic,strong) NSString * docid;
@property (nonatomic,strong) NSString *tname;
@property (nonatomic,strong) NSString * docidKey;
@property (nonatomic,strong) FMPlayingModel * playingModel;

-(void)showWindowWithMessage:(NSString*)title;

-(void)showWindow;

- (void)hideWindow;

@end
