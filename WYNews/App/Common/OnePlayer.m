//
//  OnePlayer.m
//  WYNews
//
//  Created by lanou3g on 15/6/3.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "OnePlayer.h"
#import "AppDelegate.h"

@interface OnePlayer()
{
    id _playBackTimeObserver;
    id _playBackTimeObserver_P;
    id _playBackTimeObserver_D;
    NSTimer * _myTimer;
}
@property (nonatomic,assign) CGFloat f_currentTime;
@property (nonatomic,strong) UIView * HUDView;

@end

@implementation OnePlayer

-(instancetype)init
{
    if ([super init]) {
        _isPlaying = NO;
        _isPlyed = YES;
    }
    return self;
}

+(OnePlayer*)onePlayer
{
    static OnePlayer * player = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        player = [[OnePlayer alloc]init];
    });
    return player;
}


//url初始化
-(OnePlayer*)initWithMyUrl:(NSURL*)url
{
    if (_isPlaying) {
        [self pause];
    }
    [self replaceCurrentItemWithPlayerItem:[self creatPlayerItemWithMyUrl:url]];

    //提示网络
//    [[PersistManger defoutManger] judgeNetStatusAndAlert];
    self.isPlyed = NO;
    self.failPlay = NO;
    
    [self start];
    
    return self;
}

//初始化并添加图层
-(OnePlayer*)initWithMyUrl:(NSURL *)url addToView:(UIView*)view
{
    
    if (_isPlaying) {
        [self pause];
        [self replaceCurrentItemWithPlayerItem:[self creatPlayerItemWithMyUrl:url]];
        
        [self.playerLayer removeFromSuperlayer];
        
        self.playerLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [view.layer addSublayer:self.playerLayer];
        self.HUDView = view;
        
        [self start];
    }else{
        [self replaceCurrentItemWithPlayerItem:[self creatPlayerItemWithMyUrl:url]];
        
        [self.playerLayer removeFromSuperlayer];
        
        self.playerLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [view.layer addSublayer:self.playerLayer];
        self.HUDView = view;
    }
    
    self.isPlyed = NO;
    self.failPlay = NO;
    
    return self;
}

//初始化item
-(void)initWithaPlayerItem:(AVPlayerItem*)item
{
    if (self.currentItem.status != AVPlayerStatusFailed) {
        if (self.currentItem) {
            [self removeObserverFromPlayerItem:self.currentItem];
            [self removeNotification];
        }
    }
    
    [self replaceCurrentItemWithPlayerItem:item];
    [self addNotification];
}

//创建item
-(AVPlayerItem*)creatPlayerItemWithMyUrl:(NSURL*)url
{
    _playingUrl = url;
    
    if (self.currentItem.status != AVPlayerStatusFailed) {
        if (self.currentItem) {
            [self removeObserverFromPlayerItem:self.currentItem];
            [self removeNotification];
        }
    }
    
    AVPlayerItem * playerItem = [[AVPlayerItem alloc]initWithURL:url];
    
    [self addObserberToPlayerItem:playerItem];
    [self addNotification];
    
    return playerItem;
}

//改变item
-(void)changeToItemWithMyUrl:(NSURL*)url
{
    _playingUrl = url;
    
    if (self.currentItem.status != AVPlayerStatusFailed) {
        if (self.currentItem) {
            [self removeObserverFromPlayerItem:self.currentItem];
            [self removeNotification];
        }
    }
    
    AVPlayerItem * playerItem = [[AVPlayerItem alloc]initWithURL:url];
    
    [self addObserberToPlayerItem:playerItem];
    
    [self replaceCurrentItemWithPlayerItem:playerItem];
    
    [self addNotification];
}

//改变view的layer
-(void)changeToView:(UIView*)view
{
    [self.playerLayer removeFromSuperlayer];
    
    self.playerLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
    [view.layer addSublayer:self.playerLayer];
}

//改变view的layer并新建item
-(void)changeToView:(UIView*)view WithMyUrl:(NSURL*)url
{
//    [self initWithMyUrl:url addToView:view];
    OnePlayer * one = [self initWithMyUrl:url];
    [one changeToView:view];
}

//重写getter方法
-(AVPlayerLayer*)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self];
    }
    return _playerLayer;
}

//第一次开始播放
-(void)start
{
    [super play];
}

//重写播放方法
-(void)play
{
    if (!_isPlaying) {
        [super play];
        _isPlaying = YES;
    }
}

//重写暂停方法
-(void)pause
{
    if (_isPlaying) {
        [super pause];
        _isPlaying = NO;
    }
}

//移除layer
-(void)removeOnePlayelayer
{
    [self.playerLayer removeFromSuperlayer];
    self.isPlaying = NO;
}

//结束播放
-(void)removePlayer
{
//    [self pause];
    if (_playBackTimeObserver_D) {
        [self removeTimeObserver:_playBackTimeObserver_D];
        _playBackTimeObserver_D = nil;
    }
    if (_playBackTimeObserver_P) {
        [self removeTimeObserver:_playBackTimeObserver_P];
        _playBackTimeObserver_P = nil;
    }
    if (_playBackTimeObserver) {
        [self removeTimeObserver:_playBackTimeObserver];
        _playBackTimeObserver = nil;
    }
    
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    
    self.isPlaying = NO;
    self.isPlyed = YES;
    if (self.currentItem) {
        [self removeObserverFromPlayerItem:self.currentItem];
        [self removeNotification];
            
        //将currentItem设为nil，为了防止内存泄露，采用系统方法用nil替换item
        [self replaceCurrentItemWithPlayerItem:nil];
    }
    
    [self cancelPendingPrerolls];
    [self setRate:0];
}

//判断新的URL是不是现在播放的URL
-(BOOL)isCurrentPlayingUrl:(NSURL*)url
{
    NSString * urlStr = [url absoluteString];
    NSString * isPlayingStr = [_playingUrl absoluteString];
    if ([urlStr isEqualToString:isPlayingStr]) {
        return YES;
    }else{
        return NO;
    }
}

//添加通知
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playBackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

//移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//播放结束
-(void)playBackFinished:(NSNotification*)notification
{
    NSLog(@"OnePlyer播放结束了......");
    if ([self.delegate respondsToSelector:@selector(playFinished)]) {
        [_delegate playFinished];
    }
    
    self.isPlaying = NO;
    self.isPlyed = YES;
}

//添加观察
-(void)addObserberToPlayerItem:(AVPlayerItem*)playerItem
{
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

//移除观察
-(void)removeObserverFromPlayerItem:(AVPlayerItem*)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

//观察方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        
        
        if(status==AVPlayerStatusReadyToPlay){
            self.isPlaying = YES;
            self.isPlyed = NO;
            self.failPlay = NO;
            
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            
            _totalTime = CMTimeGetSeconds(playerItem.duration);
            
            NSLog(@"onePlayer 开始播放了.........");
            if (self.delegate && [self.delegate respondsToSelector:@selector(playBegin)]) {
                [self.delegate playBegin];
                NSLog(@"isPlaying === %d",self.isPlaying);
            }
        }else if (status == AVPlayerStatusFailed){
            NSLog(@"播放失败.........");
            [self removeOnePlayelayer];
            [self removePlayer];
            self.failPlay = YES;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(playFailed)]) {
                [self.delegate playFailed];
            }
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"播放失败" message:@"请重新下载或播放！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        _currentBuffer = totalBuffer;
        
        CGFloat percentage = _currentBuffer/_totalTime;
        
        if (_downloadBlock) {
            self.downloadBlock(percentage);
        }
    }
}

//改变UI的播放进度
-(void)changePlayProgressByHandle:(ProgressBlock)progressHandle
{
    __weak OnePlayer * sself = self;
    
    if (_playBackTimeObserver_P) {
        [self removeTimeObserver:_playBackTimeObserver_P];
        _playBackTimeObserver_P = nil;
    }
   
    _playBackTimeObserver_P = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            
        CGFloat currentT = CMTimeGetSeconds(sself.currentItem.currentTime);
        CGFloat percentage = currentT/_totalTime;
            
        //bolck调用回传播放进度百分比
        progressHandle(percentage);
            
    }];
}

//改变UI的缓存进度，回传百分比
-(void)changeDownloadProgressByHandle:(ProgressBlock)downHandle
{
    //bolck调用回传缓冲进度百分比
    self.downloadBlock = ^(CGFloat percentage){
        downHandle(percentage);
    };
}

//改变UI播放进度与缓存进度，回传百分比
-(void)changePlayProgressByHandle:(ProgressBlock)progressHandle andDownProgressByHandle:(ProgressBlock)downHandle
{
    __weak OnePlayer * sself = self;
    
    //bolck调用回传缓冲进度百分比
    self.downloadBlock = ^(CGFloat percentage){
        downHandle(percentage);
    };
    
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeShowTime) userInfo:nil repeats:YES];
    
    sself.block = ^{
        CGFloat currentT = CMTimeGetSeconds(sself.currentItem.currentTime);
        CGFloat percentage = currentT/_totalTime;
        
        //bolck调用回传播放进度百分比
        progressHandle(percentage);
    };
    
    [_myTimer fire];
}

//显示播放时间
-(void)showPlayCurrenttimeAndTotaltimeByHandle:(ShowTimeBlock)showBlock
{
    __weak OnePlayer * sself = self;
    
    if (_playBackTimeObserver) {
        [self removeTimeObserver:_playBackTimeObserver];
        _playBackTimeObserver = nil;
    }
    
    _playBackTimeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        NSString * currentTime = [sself convertTime:CMTimeGetSeconds(sself.currentItem.currentTime)];
        
        NSString * totalTime = [sself convertTime:sself.totalTime];
        
        //bolck调用回传播放进度百分比
        showBlock(currentTime,totalTime);
    }];
}

//动态改变时间
-(void)changeShowTime
{
    self.block();
}

//转换播放时间
-(NSString*)convertTime:(NSTimeInterval)time
{
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formater = [[NSDateFormatter alloc]init];
    if (time/3600 >=1) {
        [formater setDateFormat:@"HH:mm:ss"];
    }else{
        [formater setDateFormat:@"mm:ss"];
    }
    
    NSString * newTimeStr = [formater stringFromDate:date];
    
    return newTimeStr;
}

//手动调节播放位置
-(void)seekToCustomTimeByHandle:(SeekBlock)seekBlock
{
//    [self pause];
    
    CGFloat percentage = seekBlock();
    
    CGFloat currentTime = _totalTime*percentage;
    
    CMTime time = CMTimeMake(currentTime, 1);
    
//    __weak OnePlayer * sself = self;
    
    if (currentTime <= _currentBuffer) {
        [self seekToTime:time completionHandler:^(BOOL finished) {
//        [sself play];
        }];
    }else{
        [self seekToTime:CMTimeMake(_currentBuffer, 1) completionHandler:^(BOOL finished) {
            
        }];
    }
}

//懒加载状态字典
-(NSMutableDictionary *)maskDic
{
    if (!_maskDic) {
        _maskDic = [NSMutableDictionary dictionary];
    }
    return _maskDic;
}

//设置播放标志，用于标记当前播放的item
-(void)setMask:(id)mask forKey:(NSString*)key
{
    [self.maskDic setValue:mask forKey:key];
}

//获取标记
-(id)getMaskByKey:(NSString*)key
{
    return [self.maskDic objectForKey:key];
}

//是否存在标记
-(BOOL)isMaskedByKey:(NSString*)key
{
    if ([self.maskDic objectForKey:key]) {
        return YES;
    }else{
        return NO;
    }
}

//自理显示播放进度//改变slider的状态
-(void)monitorProgressWith:(UIProgressView*)progress Slider:(UISlider*)slider
{
    [self changePlayProgressByHandle:^(CGFloat percentage) {
        
        if (progress) {
            progress.progress = percentage;
        }
        if (slider) {
            slider.value = percentage;
        }
    } andDownProgressByHandle:^(CGFloat percentage) {
        
    }];
}

//点击每个item播放
-(void)playAudioWithTid:(NSString*)tid andUrl:(NSString*)url toController:(FMPlayListViewController*)playListVC
{
    if (![self isMaskedByKey:tid]) {
        
        OnePlayer * onePlayer = [self initWithMyUrl:[NSURL URLWithString:url]];
        
        //设置播放标记，标记当前跳转页面正在播放
        [onePlayer.maskDic removeAllObjects];
        if (nil != tid) {
            [onePlayer setMask:tid forKey:tid];
        }
        NSLog(@"dic ------------ %@",onePlayer.maskDic);
        
//        [playListVC playRotate];
        playListVC.isPlayingIndex = 0;
        
        [onePlayer start];
        
        [playListVC.listTableView reloadData];
    }else{
        NSInteger index = [[self getMaskByKey:kIndex]integerValue];
        if (index) {
            //改变封面
//            [playListVC changeDiskCoverWithIndex:index];
            
            //回传index,标记当前应该播放的index
            playListVC.isPlayingIndex = index;
        }
        
        playListVC.continuePlay = YES;
        
        [[OnePlayer onePlayer] play];
        
        NSLog(@"diskImageView =====------- %@",playListVC.diskImgView);
    }
    
    //设置播放按钮状态
    [playListVC setupPlayPauseBTImg];
}


//push页面并播放视频，完成在不同页面点击状态栏正在播放信息，推出congtorller
-(void)playAudioFromController:(UIViewController*)viewController
{
    FMPlayListViewController * playListVC = [[FMPlayListViewController alloc]init];
    
    AudioSmallWD * smallWD = [(AppDelegate*)[[UIApplication sharedApplication]delegate] smallWindow];
    
    playListVC.cateName = smallWD.tname;
    playListVC.dbDocidKey = smallWD.docidKey;
    FMPlayingModel * playingModel = smallWD.playingModel;
    
    NSLog(@"点击了button......");
    
    NSArray * dataArr = [DataBaseHandle getDataArrayWithTitleid:smallWD.docidKey];
    if (dataArr) {
        playListVC.listModelArray = [dataArr mutableCopy];
        playListVC.playingModel = playingModel;
        
        NSInteger index = [[self getMaskByKey:kIndex]integerValue];
        if (index) {
            //改变封面
            playListVC.isPlayingIndex = index;
        }
        UIImage * img = [self getMaskByKey:kDiskImage];
        UIImage * cover = [self getMaskByKey:kDiskCover];
        [playListVC.diskImgView setDiskImage:img];
        playListVC.coverImg = cover;
        
        //设置播放按钮状态
        [playListVC setupPlayPauseBTImg];
    }else{
        //获取数据
        [PersistManger getFMPlayingDataWithUrl:smallWD.docid andByHandle:^(id model) {
            FMPlayingModel * playModel = model;
            playListVC.playingModel = playModel;
            
            //获取列表数据
            [PersistManger getFMPlayListDataWithUrl:playModel.tid page:1 andByHandle:^(NSArray *arr) {
                
                /*****设置播放页面的属性******/
                
                playListVC.listModelArray = [arr mutableCopy];
                
                [playListVC.listTableView reloadData];
                
                NSInteger index = [[self getMaskByKey:kIndex]integerValue];
                if (index) {
                    //改变封面
                    playListVC.isPlayingIndex = index;
                }
                UIImage * img = [self getMaskByKey:kDiskImage];
                UIImage * cover = [self getMaskByKey:kDiskCover];
                [playListVC.diskImgView setDiskImage:img];
                playListVC.coverImg = cover;
                
                //设置播放按钮状态
                [playListVC setupPlayPauseBTImg];
                
            }];
        }];
    }
    
    [playListVC setHidesBottomBarWhenPushed:YES];
    
    [viewController.navigationController pushViewController:playListVC animated:YES];

}







@end
