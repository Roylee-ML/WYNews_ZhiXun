//
//  NSURLSessionDownload.h
//  NSURLSessionDownload
//
//  Created by lanou3g on 15/6/17.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

typedef void(^FinishBlock)();

typedef void(^HandleBlock)();

typedef void(^ProgressBlock)(CGFloat percentage);

typedef void(^SuccessBlock)(NSURL * location);


@interface NSURLSessionDownload : NSObject<NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>


#pragma mark -------初始化-------

+(NSURLSessionDownload*)urlSessionCancellableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

+(NSURLSessionDownload*)urlSessionResumableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

+(NSURLSessionDownload*)urlSessionBackgroundTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

+(NSURLSessionDownload*)urlSessionResumableBackgroundTaskWith:(NSURL*)url andHandle:(HandleBlock)handle;


#pragma mark -------创建可以取消下载任务的task-------

//创建任务
-(void)cancellableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

//取消任务
-(void)cancellCancellableTaskAndHandle:(HandleBlock)handle;


#pragma mark -------创建可恢复的下载任务-------

//创建下载任务
-(void)resumableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

//取消下载任务
-(void)cancellResumableTask;


#pragma mark -------创建后台下载任务-------

//创建后台task
-(void)backgroundTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle;

//取消后台任务
-(void)cancellBackgroudTask;


#pragma mark -------创建可恢复后台任务-------

//创建后台任务
-(void)resumableBackgroundTaskWith:(NSURL*)url andHandle:(HandleBlock)handle;

//取消下载任务
-(void)cancellResumableBackgroundTask;

#pragma mark -------获取当前下载的data-------

//获取当前下载的data，前提是可以恢复的下载任务取消任务之后餐能获取
-(NSData*)getCurrentDownloadData;


#pragma mark -------显示UI-------

//显示下载进度
-(void)showDownloadProgressAndHandle:(ProgressBlock)handle;

//下载完成操作
-(void)downloadFinishedWithHandle:(HandleBlock)handle;

//下载成功的操作
-(void)successDownloadWithHandle:(SuccessBlock)successHandle;



@end
