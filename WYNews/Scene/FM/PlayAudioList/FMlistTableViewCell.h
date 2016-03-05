//
//  FMlistTableViewCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DownloadState){
    DownloadAvilable,
    DownloadPause,
    Downloading,
    DownloadDone
};

typedef void(^DownloadDataBlock)();

@interface FMlistTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel * titleLable;
@property (nonatomic,strong) UILabel * timeLable;
@property (nonatomic,strong) UIButton * downloadBT;
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,assign) BOOL isDownloading;

@property (nonatomic,copy) DownloadDataBlock downloadDataBlock;

//根据播放状态设置播放动画
//-(void)setupAnimateViewByState:(BOOL)isPlaying andImages:(NSArray*)imgsArray;

//播放
//-(void)start;

//暂停
//-(void)pause;

//恢复cell视图,移除动画
-(void)resumeTitlText;

-(void)resumeTitlTextRightNow;

//重建动画
-(void)showTitleText;

//设置下载按钮图片
-(void)setupDownloadBTImageWithState:(DownloadState)state;

////布局cell上的文本
//-(void)setupTextColor;


@end
