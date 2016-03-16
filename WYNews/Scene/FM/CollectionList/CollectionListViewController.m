//
//  CollectionListViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/18.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CollectionListViewController.h"
#import "OnePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+UIChangeClolor.h"
#import "AppDelegate.h"

#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height
#define BTColor [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1]

//播放进度百分比
typedef void(^ProgressBlock)(CGFloat percentage);

@interface CollectionListViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,FinishedPlay>
{
    id _playBackTimeObserver_P;
    CGFloat _currentBuffer;
    BOOL _myPlaying;
}

@property (nonatomic,strong) NSMutableArray * collectionArray;
@property (nonatomic,strong) UITableView * collectionTableView;
@property (nonatomic,assign) BOOL firstPlay;
@property (nonatomic,strong) UIButton * playPauseBT ;
@property (nonatomic,strong) UISlider * progressSlider;
@property (nonatomic,assign) BOOL isShow;
@property (nonatomic,strong) NSTimer * myTimer;

@end

@implementation CollectionListViewController

-(instancetype)init
{
    if ([super init]) {
        self.isPlayingIndex = -1;
        self.isShow = NO;
        self.firstPlay = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 配置系统替代返回按钮
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //title必须设置空，因为item由两部分组成。
    backItem.title = @"";
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    self.collectionTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NC_HEIGHT, SELF_WIDTH, SELF_HEIGHT-NC_HEIGHT) style:UITableViewStylePlain];
    _collectionTableView.separatorColor = [UIColor colorWithRed:255.0/255 green:222.0/255 blue:173.0/255 alpha:1];
    
    NSLog(@"ncheight ====== %.2f",NC_HEIGHT);
    [self.view addSubview:_collectionTableView];
    
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, 25)];
    footerView.backgroundColor = [UIColor colorWithRed:238.0/255 green:238.0/255 blue:209.0/255 alpha:1];
    self.collectionTableView.tableFooterView = footerView;
    
    [self setupNavigationViewWithTitleImg:[UIImage imageNamed:@"title1"] andBGImg:nil];
    
    //设置返回按钮
    UIButton * backBT = [[UIButton alloc]initWithFrame:CGRectMake(10,STATUS_HEIGHT+SELF_WIDTH/80 ,SELF_WIDTH*1.0/15 , SELF_WIDTH*1.0/15)];
    backBT.clipsToBounds = YES;
    backBT.layer.cornerRadius = backBT.frame.size.width/2;
    [backBT setImage:[[UIImage imageNamed:BACK_ICON_HL] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    backBT.alpha = 0.8;
    
    [backBT addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backBT.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:backBT];
    
    NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:DownLoadKey];
    if (dataArray.count != 0) {
        self.collectionArray = [dataArray mutableCopy];
        self.collectionTableView.delegate = self;
        self.collectionTableView.dataSource = self;
    }
    
    //隐藏小视窗
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    if (!dele.smallWindow.hidden) {
        [dele.smallWindow hideWindow];
    }
    
    //改变播放进度
    if ([ShareManger defoutManger].isPlayingIndex >= 0) {  //表示音乐正在播放再次进入此页面
        [[OnePlayer onePlayer]changePlayProgressByHandle:^(CGFloat percentage) {
            self.progressSlider.value = percentage;
        }];
        
        self.firstPlay = NO;
    }
    
}

-(void)back:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

//创建导航栏替换视图
-(void)setupNavigationViewWithTitleImg:(UIImage*)img andBGImg:(UIImage*)bg_img
{
    CGFloat nc_height = self.navigationController.navigationBar.frame.size.height;
    
    //用于截获响应事件
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, NC_HEIGHT+STATUS_HEIGHT)];
    [self.view addSubview:bgView];
    
    UIImageView * ncImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, NC_HEIGHT+STATUS_HEIGHT)];
    ncImgView.backgroundColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    ncImgView.image = bg_img;
    ncImgView.userInteractionEnabled = NO;
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBarHidden = YES;
    [bgView addSubview:ncImgView];
    
    UIImageView * titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH/6, nc_height*2/3)];
    
    //        titleImgView.backgroundColor = [UIColor yellowColor];
    titleImgView.image = img;
    titleImgView.clipsToBounds = YES;
    titleImgView.contentMode = UIViewContentModeScaleAspectFit;
    titleImgView.userInteractionEnabled = NO;
    titleImgView.center = CGPointMake(SELF_WIDTH/2, nc_height/2+STATUS_HEIGHT);
    
    [bgView  addSubview:titleImgView];
}

//创建播放slider
-(void)setupProgressSliderToView:(UIView*)view
{
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(LEFT_EDGE + _playPauseBT.frame.size.width, 10, SELF_WIDTH*14.0/15 - _playPauseBT.frame.size.width, SELF_WIDTH/50)];
    _progressSlider.thumbTintColor = [UIColor whiteColor];
    _progressSlider.center = CGPointMake(_progressSlider.center.x, view.center.y);
    
    UIImage * p_image = [[UIImage imageNamed:@"audionews_slider_dot"]imageWithColor:BTColor];
    
    [_progressSlider setThumbImage:p_image forState:UIControlStateNormal];
    [_progressSlider setThumbImage:p_image forState:UIControlStateHighlighted];
    
    _progressSlider.minimumValue = 0;
    _progressSlider.maximumValue =1;
    _progressSlider.value = 0.0;
    _progressSlider.alpha = 0;
    
    _progressSlider.minimumTrackTintColor = [UIColor whiteColor];
    _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1];
    
    //添加拖动事件
    [_progressSlider addTarget:self action:@selector(changePlayToTime) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:_progressSlider];
}

//改变播放进度
-(void)changePlayToTime
{
    [[OnePlayer onePlayer]seekToCustomTimeByHandle:^CGFloat{
        return _progressSlider.value;
    }];
}

//播放暂停
-(void)didClickPlayPauseButton:(UIButton*)button
{
    if (![OnePlayer onePlayer].isPlyed) {
        if ([OnePlayer onePlayer].isPlaying) {
            [self.playPauseBT setImage:[[UIImage imageNamed:@"bofang"] imageWithColor:BTColor]forState:UIControlStateNormal];
            [[OnePlayer onePlayer]pause];
        }else{
            [self.playPauseBT setImage:[[UIImage imageNamed:@"zanting"] imageWithColor:BTColor]forState:UIControlStateNormal];
            [[OnePlayer onePlayer]play];
        }
    }
}

//播放下一曲(后台控制)
-(void)playNext
{
    //改变文本颜色
    UITableViewCell * oldCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    oldCell.textLabel.textColor = [UIColor blackColor];
    
    if (_isPlayingIndex < _collectionArray.count - 1) {
        
        UITableViewCell * newCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:++_isPlayingIndex inSection:0]];
        newCell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[_isPlayingIndex];
        
        NSURL * url = [NSURL fileURLWithPath:[self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]]];
        
        OnePlayer * oneplayer = [[OnePlayer onePlayer]initWithMyUrl:url];
        [oneplayer start];
        
        NSLog(@"下载mp3url ----------- %@",url);
        NSLog(@"isPlayingindex ------ %d",(int)_isPlayingIndex);
        
        [self showControllView];
    }else if (_isPlayingIndex == _collectionArray.count - 1) {
        UITableViewCell * newCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        newCell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        _isPlayingIndex = 0;
        
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[_isPlayingIndex];
        
        NSURL * url = [NSURL fileURLWithPath:[self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]]];
        
        OnePlayer * oneplayer = [[OnePlayer onePlayer]initWithMyUrl:url];
        [oneplayer start];
        
        NSLog(@"下载mp3url ----------- %@",url);
        NSLog(@"isPlayingindex ------ %d",(int)_isPlayingIndex);
        
        [self showControllView];
    }
}

//播放上一曲(后台控制)
-(void)playForward
{
    //改变文本颜色
    UITableViewCell * oldCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    oldCell.textLabel.textColor = [UIColor blackColor];
    
    if (_isPlayingIndex > 0) {
        
        UITableViewCell * newCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:--_isPlayingIndex inSection:0]];
        newCell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[_isPlayingIndex];
        
        NSURL * url = [NSURL fileURLWithPath:[self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]]];
        
        OnePlayer * oneplayer = [[OnePlayer onePlayer]initWithMyUrl:url];
        [oneplayer start];
        
        NSLog(@"下载mp3url ----------- %@",url);
        NSLog(@"isPlayingindex ------ %d",(int)_isPlayingIndex);
        
        [self showControllView];
    }else if (_isPlayingIndex == 0) {
        _isPlayingIndex = _collectionArray.count - 1;
        
        UITableViewCell * newCell = [self.collectionTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        newCell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[_isPlayingIndex];
        
        NSURL * url = [NSURL fileURLWithPath:[self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]]];
        
        OnePlayer * oneplayer = [[OnePlayer onePlayer]initWithMyUrl:url];
        [oneplayer start];
        
        NSLog(@"下载mp3url ----------- %@",url);
        NSLog(@"isPlayingindex ------ %d",(int)_isPlayingIndex);
        
        [self showControllView];
    }
}

//设置播放图片
-(void)setupPlayPauseBTImageWith:(BOOL)isPlaying
{
    if (!isPlaying) {
        [self.playPauseBT setImage:[[UIImage imageNamed:@"bofang"] imageWithColor:BTColor] forState:UIControlStateNormal];
    }else{
        [self.playPauseBT setImage:[[UIImage imageNamed:@"zanting"] imageWithColor:BTColor] forState:UIControlStateNormal];
    }
}

//显示,隐藏控制视图
-(void)showControllView
{
    if (!_isShow) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressSlider.alpha = 1;
            self.playPauseBT.alpha = 1;
        }];
        _isShow = YES;
        
        if (_myTimer) {
            [_myTimer invalidate];
            _myTimer = nil;
        }
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(hideControllView) userInfo:nil repeats:NO];
    }
}
-(void)hideControllView
{
    if (_isShow) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressSlider.alpha = 0;
            self.playPauseBT.alpha = 0;
        }];
        _isShow = NO;
    }
}

-(void)touchShowAndHidenControllView:(UIButton*)button
{
    if (!_firstPlay) {
        if (_isShow) {
            [self hideControllView];
        }else{
            [self showControllView];
        }
    }
}

#pragma mark --------FinishedPlayDelegate--------

-(void)playBegin
{
    NSLog(@"收藏音乐开始播放了........");
    
    [self setupPlayPauseBTImageWith:[OnePlayer onePlayer].isPlaying];
    [self showControllView];
    
    if (![ShareManger defoutManger].isPlayCollection) {
        [ShareManger defoutManger].isPlayCollection = YES;
    }
}

-(void)playFinished
{
    NSLog(@"收藏音乐播放结束了........");
    [self hideControllView];
    
    [self playNext];
}

#pragma mark --------tableViewDelegate--------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _collectionArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerVeiw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, 25)];
    headerVeiw.backgroundColor = [UIColor colorWithRed:238.0/255 green:238.0/255 blue:209.0/255 alpha:1];
    
    //设置播放按钮
    self.playPauseBT = [[UIButton alloc]initWithFrame:CGRectMake(10, 2.5, 20, 20)];
    [_playPauseBT addTarget:self action:@selector(didClickPlayPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerVeiw addSubview:_playPauseBT];
    self.playPauseBT.alpha = 0;
    
    [self setupPlayPauseBTImageWith:[OnePlayer onePlayer].isPlaying];
    
    UIButton * touchButton = [[UIButton alloc]initWithFrame:CGRectMake(30, 0, SELF_WIDTH-30, 25)];
    [headerVeiw addSubview:touchButton];
    
    [touchButton addTarget:self action:@selector(touchShowAndHidenControllView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupProgressSliderToView:headerVeiw];
    
    return headerVeiw;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collectionCell"];
    }
    
    FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[indexPath.row];
    
    cell.textLabel.text = playingModel.title;
    if (_isPlayingIndex == indexPath.row) {
        if ([[OnePlayer onePlayer]isPlaying]) {
            cell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        }
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"dic ===== %@,count === %ld",[OnePlayer onePlayer].maskDic,(NSInteger)[OnePlayer onePlayer].maskDic.count);
    
    //判断player字典数的存储，清空字典数据并开启进度显示
    if ([OnePlayer onePlayer].maskDic.count != 0) {
        [[OnePlayer onePlayer].maskDic removeAllObjects];
    }
    if (self.firstPlay || [OnePlayer onePlayer].failPlay) {
        [[OnePlayer onePlayer]changePlayProgressByHandle:^(CGFloat percentage) {
            self.progressSlider.value = percentage;
        }];
        self.firstPlay = NO;
    }
    
//    if (self.isPlayingIndex < 0) {
//        [OnePlayer onePlayer].delegate = self;
//    }
    
//    if ([OnePlayer onePlayer].delegate != self) {
//        [OnePlayer onePlayer].delegate = self;
//    }
    
    [OnePlayer onePlayer].delegate = self;
    
    if (_isPlayingIndex != indexPath.row) {
        //改变文本颜色
        UITableViewCell * oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        oldCell.textLabel.textColor = [UIColor blackColor];
        
        UITableViewCell * newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.textLabel.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[indexPath.row];
        
        NSURL * url = [NSURL fileURLWithPath:[self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]]];
        
        _isPlayingIndex = indexPath.row;
        OnePlayer * oneplayer = [[OnePlayer onePlayer]initWithMyUrl:url];
        [oneplayer start];
        
        NSLog(@"下载mp3url ----------- %@",url);
        NSLog(@"isPlayingindex ------ %d",(int)_isPlayingIndex);
        
        [self showControllView];
    }
    
    [self performSelector:@selector(deselectDidSelectAtIndexpath:) withObject:indexPath afterDelay:0.05];
}

-(void)deselectDidSelectAtIndexpath:(NSIndexPath*)indexPath
{
    [self.collectionTableView deselectRowAtIndexPath:indexPath animated:YES];
}

//获取数据路径
-(NSString*)getDataPathWithString:(NSString*)path
{
    NSString * docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *  dataPath = [docuPath stringByAppendingPathComponent:path];
    
    return dataPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FMPlayingModel * playingModel = (FMPlayingModel*)_collectionArray[indexPath.row];
        [_collectionArray removeObject:playingModel];
        NSFileManager  * manger = [NSFileManager defaultManager];
        
        NSString * path = [self getDataPathWithString:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]];
        if ([manger fileExistsAtPath:path]) {
            [manger removeItemAtPath:path error:nil];
        }
        
        //删除下载记录
        [[ShareManger defoutManger]deleteDownloadMarkWith:playingModel.docid];
        
        //更新数据库
        [DataBaseHandle insertDBWWithArra:_collectionArray byID:DownLoadKey];
        
        //删除UI
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        if (_isPlayingIndex == indexPath.row) {
            [self hideControllView];
            if ([OnePlayer onePlayer].isPlaying) {
                [[OnePlayer onePlayer]pause];
                _isPlayingIndex = -1;
            }
        }
        _isPlayingIndex = _isPlayingIndex>indexPath.row?--_isPlayingIndex:_isPlayingIndex;
        
        NSLog(@"isPlayingindex ==== %d   index ====== %d",(int)_isPlayingIndex,(int)indexPath.row);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    /*注册远程事件*/
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*取消远程事件*/
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    if ([OnePlayer onePlayer].isPlaying) {
        [ShareManger defoutManger].isPlayingIndex = _isPlayingIndex;
    }
    
    if (![ShareManger defoutManger].isPlayCollection && [OnePlayer onePlayer].isPlaying) {
        [ShareManger showPlayingSmallWindow];
    }
    
//    [OnePlayer onePlayer].delegate = nil;
}

#pragma mark ---- 后台播放操作，可以操作事件播放音乐

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self didClickPlayPauseButton:nil];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self didClickPlayPauseButton:nil];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNext];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playForward];
                break;
            default:
                break;
        }
        
        NSLog(@"enentSubtype ===== %ld",(long)event.subtype);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 -(void)play
 {
 if (!_isPlaying) {
 [self.myPlayer play];
 _isPlaying = YES;
 }
 }
 
 -(void)pause
 {
 if (_isPlaying) {
 [self.myPlayer pause];
 _isPlaying = NO;
 }
 }
 
 -(void)finishPlay
 {
 if (self.myPlayer) {
 [self removeObserverFromItem:self.myPlayer.currentItem];
 [self removeNotification];
 
 if (_playBackTimeObserver_P) {
 [self.myPlayer removeTimeObserver:_playBackTimeObserver_P];
 _playBackTimeObserver_P = nil;
 }
 
 [_myPlayer cancelPendingPrerolls];
 [_myPlayer setRate:0];
 _myPlayer = nil;
 }
 }
 
 //创建player
 -(void)initMyPlayerWithUrl:(NSURL*)url
 {
 if (!_isPlayed) {
 [self removeObserverFromItem:_myPlayer.currentItem];
 [self removeNotification];
 }
 AVPlayerItem * item = [AVPlayerItem playerItemWithURL:url];
 [self addObserverToItem:item];
 
 [self.myPlayer replaceCurrentItemWithPlayerItem:item];
 
 [self addNotification];
 }
 
 -(AVPlayer*)myPlayer{
 if (!_myPlayer) {
 _myPlayer = [[AVPlayer alloc]init];
 [self changePlayProgressByHandle:^(CGFloat percentage) {
 self.progressSlider.value = percentage;
 }];
 }
 return _myPlayer;
 }
 
 -(void)addObserverToItem:(AVPlayerItem*)item
 {
 [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
 [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
 }
 
 -(void)removeObserverFromItem:(AVPlayerItem*)item
 {
 [item removeObserver:self forKeyPath:@"status"];
 [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
 }
 
 -(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
 AVPlayerItem * playerItem = object;
 if ([keyPath isEqualToString:@"status"]) {
 AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
 
 if (status == AVPlayerItemStatusReadyToPlay) {
 NSLog(@"准备播放.........");
 //开始播放的操作
 
 [self showControllView];
 self.isPlaying = YES;
 self.isPlayed = NO;
 [self setupPlayPauseBTImageWith:_isPlaying];
 
 }else if (status == AVPlayerItemStatusFailed){
 NSLog(@"播放失败.........");
 if (!_isPlayed) {
 [self removeObserverFromItem:playerItem];
 [self removeNotification];
 _isPlayed = YES;
 }
 }
 }
 //    else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
 //        NSArray *array=playerItem.loadedTimeRanges;
 //        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
 //        float startSeconds = CMTimeGetSeconds(timeRange.start);
 //        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
 //        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
 //        NSLog(@"共缓冲：%.2f",totalBuffer);
 //        _currentBuffer = totalBuffer;
 //    }
 
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
 [self hideControllView];
 self.isPlayed = YES;
 self.isPlaying = NO;
 [self setupPlayPauseBTImageWith:_isPlaying];
 [self finishPlay];
 
 if (![OnePlayer onePlayer].isPlyed) {
 [[OnePlayer onePlayer]removePlayer];
 [[OnePlayer onePlayer]removeOnePlayelayer];
 }
 NSLog(@"播放结束了........");
 }
 
 //改变UI的播放进度
 -(void)changePlayProgressByHandle:(ProgressBlock)progressHandle
 {
 if (_playBackTimeObserver_P) {
 [self.myPlayer removeTimeObserver:_playBackTimeObserver_P];
 _playBackTimeObserver_P = nil;
 }
 _playBackTimeObserver_P = [self.myPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
 CGFloat percentage = CMTimeGetSeconds(self.myPlayer.currentTime)*1.0/CMTimeGetSeconds(self.myPlayer.currentItem.duration);
 //bolck调用回传播放进度百分比
 progressHandle(percentage);
 
 }];
 }
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
