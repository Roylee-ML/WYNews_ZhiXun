//
//  OnePlayer.h
//  WYNews
//
//  Created by lanou3g on 15/6/3.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "FMPlayListViewController.h"


@protocol FinishedPlay <NSObject>

@optional
-(void)playBegin;

-(void)playFinished;

-(void)playFailed;

@end

//播放进度百分比
typedef void(^ProgressBlock)(CGFloat percentage);

//播放时间显示
typedef void(^ShowTimeBlock)(NSString * currentTime,NSString * totalTime);

//显示时间跳转
typedef void(^Block)();

//手动调节播放位置
typedef CGFloat(^SeekBlock)();

////显示进度占位
//typedef void(^HUDBlock)();

@interface OnePlayer : AVPlayer

@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic,copy) ProgressBlock downloadBlock;
@property (nonatomic,copy) Block block;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isPlyed;
@property (nonatomic,assign) BOOL failPlay;
@property (nonatomic,assign) id<FinishedPlay> delegate;
@property (nonatomic,strong) NSURL * playingUrl;
@property (nonatomic,assign) CGFloat currentBuffer;
@property (nonatomic,strong) NSMutableDictionary * maskDic;
@property (nonatomic,assign) CGFloat totalTime;
@property (nonatomic,strong) UIViewController * playingController;


//创建player，但是没有初始化URL
+(OnePlayer*)onePlayer;

//url初始化，这个方法可以不用创建player，直接初始好播放的item
-(OnePlayer*)initWithMyUrl:(NSURL*)url;

//初始化并添加图层
-(OnePlayer*)initWithMyUrl:(NSURL *)url addToView:(UIView*)view;

//改变item
-(void)changeToItemWithMyUrl:(NSURL*)url;

//改变view的layer
-(void)changeToView:(UIView*)view;

//改变view的layer并新建item
-(void)changeToView:(UIView*)view WithMyUrl:(NSURL*)url;

//结束播放
-(void)removePlayer;

//改变UI的播放进度,回传播放百分比
-(void)changePlayProgressByHandle:(ProgressBlock)progressHandle;

//改变UI的缓存进度，回传百分比
-(void)changeDownloadProgressByHandle:(ProgressBlock)downHandle;

//改变UI播放进度与缓存进度，回传百分比
-(void)changePlayProgressByHandle:(ProgressBlock)progressHandle andDownProgressByHandle:(ProgressBlock)downHandle;

//显示播放时间
-(void)showPlayCurrenttimeAndTotaltimeByHandle:(ShowTimeBlock)showBlock;

//手动调节播放位置
-(void)seekToCustomTimeByHandle:(SeekBlock)seekBlock;

//第一次开始播放
-(void)start;

//重写播放方法
-(void)play;

//重写暂停方法
-(void)pause;

//移除layer
-(void)removeOnePlayelayer;

//判断新的URL是不是现在播放的URL
-(BOOL)isCurrentPlayingUrl:(NSURL*)url;

//设置播放标志，用于标记当前播放的item
-(void)setMask:(id)mask forKey:(NSString*)key;

//获取标记
-(id )getMaskByKey:(NSString*)key;

//是否存在标记
-(BOOL)isMaskedByKey:(NSString*)key;

//自理显示播放进度//改变slider的状态
-(void)monitorProgressWith:(UIProgressView*)progress Slider:(UISlider*)slider;

//push页面并播放视频，完成在不同页面点击状态栏正在播放信息，推出congtorller
-(void)playAudioFromController:(UIViewController*)viewController;

//点击每个item播放
-(void)playAudioWithTid:(NSString*)tid andUrl:(NSString*)url toController:(FMPlayListViewController*)playListVC;


@end
