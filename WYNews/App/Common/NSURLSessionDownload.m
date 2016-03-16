//
//  NSURLSessionDownload.m
//  NSURLSessionDownload
//
//  Created by lanou3g on 15/6/17.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "NSURLSessionDownload.h"


#define kCurrentSession @"currentSessionKey"
#define kBackgroundSessionID @"backgroundSessionID"
#define kBackgroudSession @"backgroudSession"

#define ResumPath @"resumTask.text"
#define ResumBGpath @"resumBGTask.text"

typedef NS_ENUM(NSInteger, NSURLSessionDownloadOrder) {
    Download,
    CancellDownload
};

@interface NSURLSessionDownload()

/*NSURLSession*/
@property (nonatomic,strong) NSURLSession * currentSession;
@property (nonatomic,strong) NSURLSession * backgroundSession;

/*下载任务*/
@property (nonatomic,strong) NSURLSessionDownloadTask * cancellableTask;    //可取消的下载任务
@property (nonatomic,strong) NSURLSessionDownloadTask * resumableTask;      //可恢复的下载任务
@property (nonatomic,strong) NSURLSessionDownloadTask * backgroundTask;     //后台下载任务
@property (nonatomic,strong) NSURLSessionDownloadTask * resumableBckgroudTask; //可以恢复的后台下载

/*可恢复下载任务的临时数据存储*/
@property (nonatomic,strong) NSData * partialData;
@property (nonatomic,strong) NSMutableData * currentData;
@property (nonatomic,strong) NSString * resumePath;

@property (nonatomic,copy) ProgressBlock progressBlock;
@property (nonatomic,copy) HandleBlock finishBlock;
@property (nonatomic,copy) SuccessBlock successBlock;

@end


@implementation NSURLSessionDownload

#pragma mark -------初始化-------

-(instancetype)init
{
    if ([super init]) {
    /*
        //保证多任务恢复下载时的临时存储路径各不相同。允许连续创建50个可恢复下载的对象。
        int num = arc4random()%([PersistManger defoutManger].pathNumArray.count);
        self.resumePath = [NSString stringWithFormat:@"resumTask%@.text",[PersistManger defoutManger].pathNumArray[num]];
        [[PersistManger defoutManger].pathNumArray removeObject:[PersistManger defoutManger].pathNumArray[num]];
    */
        //随机临时路径，保证多任务下载时，可恢复任务的临时路径不容。但仍有局限性。
        self.resumePath = [NSString stringWithFormat:@"resumTask%d.text",arc4random()%1000];
    
        //进入后台删除临时数据，不允许后台模式。
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteTempDataPath:) name:UIApplicationWillResignActiveNotification object:nil];
        
    }
    return self;
}

-(void)deleteTempDataPath:(NSNotification*)notification
{
    [self deletePartialDataAtPath:_resumePath];
}

+(NSURLSessionDownload*)urlSessionCancellableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    NSURLSessionDownload * sessionDownload = [[NSURLSessionDownload alloc]init];
    [sessionDownload cancellableTaskWithUrl:url andHandle:^{
        if (handle) {
            handle();
        }
    }];
    return sessionDownload;
}

+(NSURLSessionDownload*)urlSessionResumableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    NSURLSessionDownload * sessionDownload = [[NSURLSessionDownload alloc]init];
    
    [sessionDownload resumableTaskWithUrl:url andHandle:^{
        if (handle) {
            handle();
        }
    }];
    return sessionDownload;
}

+(NSURLSessionDownload*)urlSessionBackgroundTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    NSURLSessionDownload * sessionDownload = [[NSURLSessionDownload alloc]init];
    [sessionDownload backgroundTaskWithUrl:url andHandle:^{
        if (handle) {
            handle();
        }
    }];
    return sessionDownload;
}

+(NSURLSessionDownload*)urlSessionResumableBackgroundTaskWith:(NSURL*)url andHandle:(HandleBlock)handle

{
    NSURLSessionDownload * sessionDownload = [[NSURLSessionDownload alloc]init];
    [sessionDownload resumableBackgroundTaskWith:url andHandle:^{
        if (handle) {
            handle();
        }
    }];
    return sessionDownload;
}

#pragma mark -------创建可以取消下载任务的task-------

//创建任务
-(void)cancellableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    if (!self.cancellableTask) {
        if (!self.currentSession) {
            [self createDefaultCurrentsession];
        }
        
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        self.cancellableTask = [self.currentSession downloadTaskWithRequest:request];
        
        [self.cancellableTask resume];
        
        if (handle) {
            handle();
        }
    }
}

//初始化session
-(void)createDefaultCurrentsession
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.currentSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.currentSession.sessionDescription = kCurrentSession;
}

//取消任务
-(void)cancellCancellableTaskAndHandle:(HandleBlock)handle
{
    if (self.cancellableTask) {
        [self.cancellableTask cancel];
        self.cancellableTask = nil;
        
        if (handle) {
            handle();
        }
    }
}

#pragma mark -------创建可恢复的下载任务-------

//创建下载任务
-(void)resumableTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    if (!self.resumableTask) {
        if (!self.currentSession) {
            [self createDefaultCurrentsession];
        }
        
        if ((self.partialData = [self getPartialDataAtPath:_resumePath])) {
            
            [self deletePartialDataAtPath:_resumePath];
            
            //恢复数据
            self.resumableTask = [self.currentSession downloadTaskWithResumeData:self.partialData];
        }else{
            //新建数据
            NSURLRequest * request = [NSURLRequest requestWithURL:url];
            
            self.resumableTask = [self.currentSession downloadTaskWithRequest:request];
        }
        
        [self.resumableTask resume];
        
        if (handle) {
            handle();
        }
    }
}

//取消下载任务
-(void)cancellResumableTask
{
    if (self.resumableTask) {
        [self.resumableTask cancelByProducingResumeData:^(NSData *resumeData) {
            
            [self saveData:resumeData InPath:_resumePath];
            
            self.partialData = resumeData;
            
            self.resumableTask = nil;
        }];
    }
}

//创建临时数据保存路径
-(void)saveData:(NSData*)data InPath:(NSString*)path
{
    NSString * catchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString * dataPath = [catchPath stringByAppendingString:path];
    
    [data writeToFile:dataPath atomically:YES];
}

//获取临时数据
-(NSData*)getPartialDataAtPath:(NSString*)path
{
    NSData * data = [NSData data];
    
    NSString * catchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString * dataPath = [catchPath stringByAppendingString:path];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:dataPath]) {
        data = [manager contentsAtPath:dataPath];
        
        return data;
    }
    return nil;
}

//删除临时存储数据
-(void)deletePartialDataAtPath:(NSString*)path
{
    NSString * catchPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString * dataPath = [catchPath stringByAppendingString:path];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:dataPath]) {
        [manager removeItemAtPath:dataPath error:nil];
    }
}

#pragma mark -------创建后台下载任务-------

//创建后台task
-(void)backgroundTaskWithUrl:(NSURL*)url andHandle:(HandleBlock)handle
{
    if (!self.backgroundTask) {
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        
        self.backgroundTask = [self.backgroundSession downloadTaskWithRequest:request];
        
        [self.backgroundTask resume];
        
        if (handle) {
            handle();
        }
    }
}

//懒加载后台session
-(NSURLSession*)backgroundSession
{
    static NSURLSession * backgroudSession = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionID];
        backgroudSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        backgroudSession.sessionDescription = kBackgroudSession;
        
    });
    return backgroudSession;
}

//取消后台任务
-(void)cancellBackgroudTask
{
    if (self.backgroundTask) {
        [self.backgroundTask cancel];
        self.backgroundTask = nil;
    }
}

#pragma mark -------创建可恢复后台任务-------

//创建后台任务
-(void)resumableBackgroundTaskWith:(NSURL*)url andHandle:(HandleBlock)handle
{
    if (!self.resumableBckgroudTask) {
        if ([self getPartialDataAtPath:ResumBGpath]) {
            NSData * partialData = [self getPartialDataAtPath:ResumBGpath];
            
            [self deletePartialDataAtPath:ResumBGpath];
            
            self.resumableBckgroudTask = [self.backgroundSession downloadTaskWithResumeData:partialData];
        }else{
            NSURLRequest * request = [NSURLRequest requestWithURL:url];
            
            self.resumableBckgroudTask = [self.backgroundSession downloadTaskWithRequest:request];
        }
        
        [self.resumableBckgroudTask resume];
        
        if (handle) {
            handle();
        }
    }
}

//取消下载任务
-(void)cancellResumableBackgroundTask
{
    if (self.resumableBckgroudTask) {
        [self.resumableBckgroudTask cancelByProducingResumeData:^(NSData *resumeData) {
            [self saveData:resumeData InPath:ResumBGpath];
            
            self.partialData = resumeData;
        }];
        
        self.resumableBckgroudTask = nil;
    }
}

#pragma mark -------获取当前下载的data-------

-(NSData*)getCurrentDownloadData
{
    if (self.partialData) {
        return _partialData;
    }else{
        return nil;
    }
}

#pragma mark -------显示UI-------

//显示下载进度
-(void)showDownloadProgressAndHandle:(ProgressBlock)handle
{
    self.progressBlock = handle;
}

//下载完成操作
-(void)downloadFinishedWithHandle:(HandleBlock)handle
{
    self.finishBlock = handle;
}

//下载成功的操作
-(void)successDownloadWithHandle:(SuccessBlock)successHandle
{
    self.successBlock = successHandle;
}

#pragma mark -------NSURLSessionDownloadDelegate-------


/* 从fileOffset位移处恢复下载任务 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
}


/* 完成下载任务，无论下载成功还是失败都调用该方法 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"NSURLSessionDownloadDelegate: Complete task");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.finishBlock) {
            self.finishBlock();
        }
        
        if (error) {
            NSLog(@"下载失败：%@", error);
            if (self.backgroundTask) {
                [self.backgroundTask cancel];
                self.backgroundTask = nil;
            }
            if (self.resumableBckgroudTask) {
                [self.resumableBckgroudTask cancel];
                self.resumableBckgroudTask = nil;
            }
            if (self.resumableTask) {
                [self.resumableTask cancel];
                self.resumableTask = nil;
            }
            if (self.cancellableTask) {
                [self.cancellableTask cancel];
                self.cancellableTask = nil;
            }
        }
    });
}

/* 下载成功调用的方法 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.successBlock) {
            self.successBlock(location);
        }
    });
    
    NSLog(@"下载成功：location == %@",location);
}

/* 执行下载任务时有数据写入 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten // 每次写入的data字节数
 totalBytesWritten:(int64_t)totalBytesWritten // 当前一共写入的data字节数
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite // 期望收到的所有data字节数
{
    CGFloat percentage = totalBytesWritten*1.0/totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) {
            self.progressBlock(percentage);
        }
    });
    
    NSLog(@"正在下载.........%.2f",percentage);
}


@end
