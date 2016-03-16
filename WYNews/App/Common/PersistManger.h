//
//  PersistManger.h
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoModel.h"
#import "FMModel.h"
#import "NewsAPIUrl.h"
#import "FMPlayingModel.h"
#import "FMListModel.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "MVideo.h"
#import "SDRefreshFooterView.h"
#import "SDRefreshHeaderView.h"

typedef void(^DataBlock)(id obj);
typedef void(^FMDataBlock)(NSDictionary * dic);
typedef void(^PlayBlock)(id model);
typedef void(^RefreshBlock)();
typedef void(^RefreshHDBlock)();
//显示进度占位
typedef void(^HUDBlock)();

typedef void(^PlaceBlock)();


typedef void(^Back)(NSArray * dataArray);

//用于实现点击音乐列表页面的item播放音乐的协议
@protocol PlayFMVideoDelegate <NSObject>

-(void)playFMAudioWithaDocid:(NSString*)docid tname:(NSString*)tname andImage:(UIImage*)img;

@end

//用于隐藏小视窗，并推出之前播放音乐的页面
@protocol ShowPlayingAudio <NSObject>

-(void)showPlayingAudioAndHidenSmallWindow;

@end

@interface PersistManger : NSObject

@property (nonatomic,assign) id<PlayFMVideoDelegate> playDelegate;
@property (nonatomic,assign) id<ShowPlayingAudio> showDelegate;



//新闻列表属性
//@property(nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) Back back;
@property (nonatomic,strong) DataModel * dataModel;

//收藏音乐列表播放属性
@property (nonatomic,assign) NSInteger isPlayingIndex;
@property (nonatomic,assign) BOOL isPlayCollection;

//下载任务随机路径
@property (nonatomic,strong) NSMutableArray * pathNumArray;


+(PersistManger*)defoutManger;

//解析视频数据
+(void)getModelWithUrl:(NSURL*)url andByHandle:(DataBlock)block;

+ (void)getVideoListWithUrl:(NSURL*)url
                 mVideoList:(MVideoList *)videoList
         complicationHandle:(DataBlock)result
                errorHandle:(void(^)(NSError * error))errorHandle;

//解析电台数据
+(void)getFMDataWithUrl:(NSURL*)url andByHandle:(FMDataBlock)block;

//解析播放数据-获取正在播放数据
+(void)getFMPlayingDataWithUrl:(NSString*)docid andByHandle:(PlayBlock)playBlock;

//解析播放数据-获取播放列表数据
+(void)getFMPlayListDataWithUrl:(NSString*)tid page:(int)page andByHandle:(DataBlock)listBlock;

//解析板块列表数据
+(void)getFMCateListDataWithUrl:(NSString*)cid page:(int)page andByHandel:(DataBlock)cateBlock;

//创建推出页面播放显示小窗口
+(void)showPlayingSmallWindowWith:(FMPlayingModel*)playingModel name:(NSString*)cateName title:(NSString*)title dbKey:(NSString*)dockey;

//显示小视窗
+(void)showPlayingSmallWindow;

//隐藏小视窗
+(void)hidenSmallWindow;

//创建导航栏替换视图
-(void)setupNavigationViewToVC:(UIViewController*)viewController withTitleImg:(UIImage*)img andBGImg:(UIImage*)bg_img;

//解析新闻页面数据
+(void)jsonDataUrl:(NSString *)url Stringkey:(NSString *)str andByHandle:(Back)back;

//添加标记
+(void)setMarkWithMark:(NSString*)mark;

//判断标记是否存在
+(BOOL)isMarkedWithMark:(NSString*)mark;

//设置固定标记
+(void)setMark:(NSString*)mark;

//获取标记
+(NSString*)getMark;

//存储音乐刷新页数
+(void)setRefreshPage:(NSInteger)page;

//获取音乐刷新页数
+(NSInteger)getRefreshPage;

//上拉加载
-(void)refreshFooterToView:(UIScrollView*)scroollView andEndByHandle:(RefreshBlock)handle;

//下拉刷新
//-(void)refreshHeaderToView:(UIScrollView*)scrollView andEndByHandle:(RefreshHDBlock)hd_handle;

//获取网路状态
+(NSString*)networkingStatusFromStatebar;

//判断设备网络
-(void)judgeNetStatusAndAlert;

//显示网络不好数据加载失败提示框
+(void)showConnectToNetFail;

//显示占位进度
-(void)showProgressHUDToView:(UIView*)view overTimeByHandle:(HUDBlock)handle;

//隐藏占位进度
-(void)hideProgressHUD;

//移除进度条
-(void)removeHUD;

//添加占位图片
-(void)placeHoderViewToView:(UIView*)view;

//移除占位图
-(void)removeHoderView;

//获取文件字节大小
+(NSUInteger)getFileSizeAtPath:(NSString*)path;

+(void)clearAlertShowByVC:(UIViewController*)controller;

#pragma maek -------下载记录设置，沙盒永久存储
//设置记录
-(void)setDownloadMarkWith:(NSString*)mark;

//判断记录是否存在
-(BOOL)isDownloadWith:(NSString*)mark;

//删除下载记录
-(void)deleteDownloadMarkWith:(NSString*)mark;

//删除所有下载记录
-(void)deleteAllDownloadMark;

#pragma mark -------正在下载记录,临时存储
//设置正在下载标记
-(void)setDownloadingMarkWith:(NSString*)mark;

//判断正在下载标记是否存在
-(BOOL)isDownloadingWith:(NSString*)mark;

//删除一个标记
-(void)deleteDownloadingMarkWith:(NSString*)mark;

//删除所有正在下载标记
-(void)deleteAllDownloadingMark;

@end
