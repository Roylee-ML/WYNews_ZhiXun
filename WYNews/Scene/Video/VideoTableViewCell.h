//
//  VideoTableViewCell.h
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import "UIImageView+WebCache.h"
#import "OnePlayer.h"


typedef NS_ENUM(NSInteger, PlayStatus) {
    Playing,
    Pause
};


typedef void(^VideoBlock)(UIImageView *,UISlider *,NSString *);
typedef void(^BTBlock)(PlayStatus);

@interface VideoTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (nonatomic,copy) VideoBlock videoBlock;

@property (strong, nonatomic)  UILabel *descripLable;

@property (strong, nonatomic)  UIImageView *timeImgView;

@property (strong, nonatomic)  UILabel *timeLable;

@property (strong, nonatomic)  UIImageView *countImgView;

@property (strong, nonatomic)  UIImageView *videoImgView;


@property (strong, nonatomic)  UILabel *playCountLable;

@property (strong, nonatomic)  UIImageView *replayBGImgView;

@property (strong, nonatomic)  UILabel *replayCuntLable;

@property (strong, nonatomic)  UILabel *replayLable;

@property (strong, nonatomic)  UIButton *playVideoBT;

@property (nonatomic,strong) VideoModel * videoModel;

@property (strong, nonatomic) UISlider *playProgress;

@property (nonatomic,strong) UIButton * playPauseBT;

@property (nonatomic,assign) PlayStatus playStatus;

@property (nonatomic,copy) BTBlock playBlock;

@property (nonatomic,assign) NSInteger clickCell;         //记录连续点击次数

@property (nonatomic,strong) UIView * controllView;


//创建开始按钮
-(void)showPlayButton;

//创建进度指示视图
-(void)setupPlayStatusControllView;

//显示控制视图
-(void)showCotrollView;

//记录点击次数延时消失controllView
-(void)recordClickTimes;

-(void)hideControllViewRightNow;

//隐藏开始按钮
-(void)hidePlayButton;

//记录播放进度
-(void)showPlayProgress;

-(void)hideControllView;

//设置播放按钮状态
-(void)setupPlayAndPauseBT;

@end
