//
//  FMPlayListViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "FMPlayingModel.h"
#import "FMlistTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioSmallWD.h"
#import "DiskAnimateView.h"
#import "AudioAnimateView.h"

typedef void(^ShowBarBlock)();
typedef void(^AudioBlock)(FMPlayingModel*playModle);

@interface FMPlayListViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray * listModelArray;
@property (nonatomic,strong) DiskAnimateView * diskImgView;
@property (nonatomic,strong) FMPlayingModel * playingModel;
@property (nonatomic,copy) ShowBarBlock block;
@property (nonatomic,strong) UITableView * listTableView;
@property (nonatomic,strong) UIImageView * bgImgView;
@property (readonly,nonatomic,strong) AVPlayer * myPalyer;
@property (nonatomic,assign) NSInteger isPlayingIndex;
@property (nonatomic,strong) FMPlayingModel * playModel;
@property (nonatomic,strong) NSString * cateName;  //用于传递给播放小提示window的标题参数
@property (nonatomic,strong) UIImage * coverImg;
@property (nonatomic,strong) NSString * dbDocidKey;
@property (nonatomic,strong) AudioAnimateView * animateView;
@property (nonatomic,assign) BOOL continuePlay;


////初始化avplayer,并添加图层，播放操作
//-(void)creatMyPlayerWithUrl:(NSString*)urlStr andAddToView:(UIView*)view;
//
////切换视图层
//-(void)changeToLayerOfOtherView:(UIView*)view;

//创建开始disk
-(void)playRotate;

//播放disk图片
-(void)startRotate;

//暂停disk图片
-(void)pauseRotate;

//请求加载disk封面
-(void)changeDiskCoverWithIndex:(NSInteger)index;

//设置播放按钮
-(void)setupPlayPauseBTImg;

//数据库读取数据时,避免视图推出而没有创建的发生
-(void)setupPlayImageAndTileWith:(FMPlayingModel *)playingModel;

//获取播放音频文件
-(void)getAudioWithIndex:(NSInteger)index andByHandle:(AudioBlock)handle;

@end
