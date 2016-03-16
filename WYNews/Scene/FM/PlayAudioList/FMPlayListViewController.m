//
//  FMPlayListViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//


#import "FMPlayListViewController.h"
#import "FMListModel.h"
#import "CommonDefined.h"
#import "OnePlayer.h"
#import "NSURLSessionDownload.h"


#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height

#define COVER_IMG [UIImage imageNamed:HODER_IMG]

typedef void(^StopRunloop)();

@interface FMPlayListViewController ()<FinishedPlay>

@property (nonatomic,strong) UIButton * playPauseBT;
@property (nonatomic,strong) UIButton * nextBT;
@property (nonatomic,strong) UIButton * previousBT;
@property (nonatomic,strong) UIButton * backBT;
@property (nonatomic,strong) UILabel * playCountLable;
@property (nonatomic,strong) UISlider * progressSlider;
@property (nonatomic,strong) UILabel * totalTime;
@property (nonatomic,strong) UILabel * currentTime;
@property (nonatomic,strong) UILabel * titleLable;
@property (nonatomic,strong) NSTimer * myTimer;
@property (nonatomic,assign) CGAffineTransform transform;
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) UIImageView * playBGImgView;
@property (nonatomic,assign) CGPoint beginPoint;
@property (readwrite,nonatomic,strong) AVPlayer * myPalyer;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic,assign) int pageCount;
@property (nonatomic,copy) StopRunloop stopRunloopBlock;
@property (nonatomic,strong) NSArray * audioAnimateArray; //用于存储animateView，防止它的引用计数变为零被系统销毁。
@property (nonatomic,assign) BOOL isAppAvtive;
@property (nonatomic,strong) NSMutableDictionary * downloadObjectDic;
//@property (nonatomic,strong) CustomTimer * myTimer;


@end

@implementation FMPlayListViewController

-(instancetype)init
{
    if ([super init]) {
        self.pageCount = 1;
        
        //设置默认的播放index，用于显示播放动画
        self.isPlayingIndex = 0;
        //注册程序进入后台通知，取消视播放
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeInActiveStopVideo) name:UIApplicationWillResignActiveNotification object:nil];
        
        //注册回到前台通知，继续播放视频或者做其他操作
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeActiveGoonPlay) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        self.isAppAvtive = YES;
        self.continuePlay = NO;
        
        //重置收藏列表的播放下标
        [PersistManger defoutManger].isPlayingIndex = -1;
        [PersistManger defoutManger].isPlayCollection = NO;
    }
    return self;
}

-(void)appBecomeInActiveStopVideo
{
    self.isAppAvtive = NO;
}

-(void)appBecomeActiveGoonPlay
{
    self.isAppAvtive = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupPlayUI];
    
    [self setupTableView];
    
    NSLog(@"playmodel ===== %@",_playingModel);
    
    //用于直接属性传值导致对象没有创建的情况
    if (!self.continuePlay) {
        [self setupPlayImageAndTileWith:_playingModel];
    }else{
        UIImage * img = [[OnePlayer onePlayer] getMaskByKey:kDiskImage];
        [self.diskImgView setDiskImage:img];
    }
    
    self.navigationController.navigationBar.alpha = 0;


    // 配置返回按钮
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //title必须设置空，因为item由两部分组成。
    backItem.title = @"";
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }

    
    //改变播放进度
    [self monitorSlider];
    
    //显示播放时间
    [self showPlayingTime];
    
    [OnePlayer onePlayer].delegate = self;
    [OnePlayer onePlayer].playingController = self;
    
    NSInteger page = [PersistManger getRefreshPage];
    if (page) {
        _pageCount = (int)page;
    }
    
    self.listTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [PersistManger getFMPlayListDataWithUrl:_playingModel.tid page:++ _pageCount andByHandle:^(NSArray *arr) {
            if (arr.count != 0) {
                [self.listModelArray addObjectsFromArray:arr];
                [self.listTableView reloadData];
                
                [DataBaseHandle insertDBWWithArra:_listModelArray byID:self.dbDocidKey];
                [PersistManger setRefreshPage:_pageCount];
                
                [self.listTableView.footer endRefreshing];
            }else{
                [self.listTableView.footer endRefreshing];
            }
        }];
    }];
    
    NSLog(@"array ============ %@",_listModelArray);
    
    self.downloadObjectDic = [@{} mutableCopy];

}

-(void)setupPlayUI
{
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusH = rectStatus.size.height;
    
//创建背景图片
    self.bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, SELF_WIDTH*3/5)];
    
    _bgImgView.backgroundColor = [UIColor whiteColor];
    _bgImgView.image = [UIImage imageNamed:@"huayujie"];
    _bgImgView.clipsToBounds = YES;
    [self.view addSubview:_bgImgView];
    
//创建碟片图片
    self.diskImgView = [[DiskAnimateView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*8.0/27, SELF_WIDTH*8.0/27)];
    _diskImgView.center = CGPointMake(SELF_WIDTH*1.0/2, _bgImgView.center.y);
   
    _diskImgView.layer.cornerRadius = (SELF_WIDTH*7.2/27)/2;
    [_diskImgView setClipsToBounds:YES];
    _diskImgView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:_diskImgView];
    
//创建播放暂停按钮
    self.playPauseBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*1.0/8, SELF_WIDTH*1.0/8)];
    _playPauseBT.center = _diskImgView.center;
    
    _playPauseBT.layer.cornerRadius = SELF_WIDTH*1.0/16;
    [_playPauseBT setClipsToBounds:YES];
    [self setupPlayPauseBTImg];
    
    [_playPauseBT addTarget:self action:@selector(didClickPlayAndPause:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_playPauseBT];
    
//创建标题
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(SELF_WIDTH*1.0/6, statusH + SELF_WIDTH/80, SELF_WIDTH*2.0/3, SELF_WIDTH*1.0/20)];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.font = [UIFont boldSystemFontOfSize:17];
    
    [self.view addSubview:_titleLable];
    
//创建返回按钮
    self.backBT = [[UIButton alloc]initWithFrame:CGRectMake(10, _titleLable.frame.origin.y, SELF_WIDTH*1.0/15, SELF_WIDTH*1.0/15)];
    _backBT.clipsToBounds = YES;
    _backBT.layer.cornerRadius = _backBT.frame.size.width/2;
    [_backBT setImage:[[UIImage imageNamed:BACK_ICON_HL] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    _backBT.alpha = 0.8;
    
    [_backBT addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    _backBT.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:_backBT];
    
//创建上一曲按钮
    self.previousBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*1.0/10, SELF_WIDTH/10)];
    _previousBT.center = CGPointMake(SELF_WIDTH*1.0/5, _diskImgView.center.y);
    
    _previousBT.tintColor = [UIColor whiteColor];
    _previousBT.alpha = 0.7;
    [_previousBT setImage:[[UIImage imageNamed:@"shangyiqu"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_previousBT addTarget:self action:@selector(playForward:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_previousBT];
    
//创建下一曲按钮
    self.nextBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*1.0/10, SELF_WIDTH/10)];
    _nextBT.center = CGPointMake(SELF_WIDTH*4.0/5, _diskImgView.center.y);
    
    [_nextBT setImage:[[UIImage imageNamed:@"xiayiqu"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    _nextBT.tintColor = [UIColor whiteColor];
    _nextBT.alpha = 0.7;
    [_nextBT addTarget:self action:@selector(playNext:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_nextBT];

//创建播放slider
    [self setupProgressSlider];
    
    //创建播放时间
    self.currentTime = [[UILabel alloc]initWithFrame:CGRectMake(_progressSlider.frame.origin.x,_progressSlider.frame.origin.y + _progressSlider.frame.size.height, SELF_WIDTH/10, SELF_WIDTH/20)];
    _currentTime.font = [UIFont systemFontOfSize:12];
    _currentTime.text = @"0";
    
    [self.view addSubview:_currentTime];
    
//创建播放总时长
    self.totalTime = [[UILabel alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/10 - LEFT_EDGE, _currentTime.frame.origin.y, _currentTime.frame.size.width, _currentTime.frame.size.height)];
    _totalTime.font = [UIFont systemFontOfSize:12];
    _totalTime.textAlignment = NSTextAlignmentRight;
    _totalTime.text = @"0";
    
    [self.view addSubview:_totalTime];
    
}

//创建播放slider
-(void)setupProgressSlider
{
    self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(LEFT_EDGE, SELF_WIDTH*3.0/5 - SELF_WIDTH/13, SELF_WIDTH - 2*LEFT_EDGE, SELF_WIDTH/50)];
    _progressSlider.thumbTintColor = [UIColor whiteColor];
    
    
    UIImage * p_image = [[UIImage imageNamed:@"audionews_slider_dot"]imageWithColor:[UIColor whiteColor]];
    
    [_progressSlider setThumbImage:p_image forState:UIControlStateNormal];
    [_progressSlider setThumbImage:p_image forState:UIControlStateHighlighted];
    
    
    _progressSlider.minimumValue = 0;
    _progressSlider.maximumValue =1;
    _progressSlider.value = 0.0;
    
    _progressSlider.minimumTrackTintColor = [UIColor whiteColor];
    _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1];
    
    //添加拖动事件
    [_progressSlider addTarget:self action:@selector(changePlayToTime) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_progressSlider];
}

//改变slider的状态
-(void)monitorSlider
{
    self.progressSlider.value = 0;
    
    __weak FMPlayListViewController * sself = self;
    
    [[OnePlayer onePlayer]changePlayProgressByHandle:^(CGFloat percentage) {
        
        sself.progressSlider.value = percentage;
        
    } andDownProgressByHandle:^(CGFloat percentage) {
        
    }];
}

//改变播放时间
-(void)changePlayToTime
{
    NSTimeInterval toTime = self.progressSlider.value;
    
    //获取当前缓存进度
    CGFloat currentBuffer = [OnePlayer onePlayer].currentBuffer;
    CGFloat totalTime = [OnePlayer onePlayer].totalTime;
    
    //改变后的播放时间要小于缓存进度
    if (toTime*totalTime <= currentBuffer) {
        [[OnePlayer onePlayer]seekToCustomTimeByHandle:^CGFloat{
            return toTime;
        }];
    }else{
        //还原slider位置
        self.progressSlider.value = CMTimeGetSeconds([[OnePlayer onePlayer]currentTime])/[OnePlayer onePlayer].totalTime;
    }
}

//显示时间
-(void)showPlayingTime
{
    __weak FMPlayListViewController * ssef = self;
    
    [[OnePlayer onePlayer]showPlayCurrenttimeAndTotaltimeByHandle:^(NSString *currentTime, NSString *totalTime) {
        ssef.currentTime.text = currentTime;
        ssef.totalTime.text = totalTime;
    }];
}

//创建tableview
-(void)setupTableView
{
    self.listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.bgImgView.frame.size.height, SELF_WIDTH, SELF_HEIGHT - self.bgImgView.frame.size.height) style:UITableViewStylePlain];
    
    _listTableView.delegate = self;
    _listTableView.dataSource =self;
    
    [self.view addSubview:_listTableView];
    
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, 15)];
    footerView.backgroundColor = [UIColor colorWithRed:223.0/255 green:220.0/255 blue:213.0/255 alpha:0.8];
    _listTableView.tableFooterView = footerView;
    
}

//懒加载设置音乐动画
-(AudioAnimateView*)animateView
{
    if (!_animateView) {
        _animateView = [[AudioAnimateView alloc]initWithFrame:CGRectMake(LEFT_EDGE, 0, SELF_WIDTH/15, SELF_WIDTH/15) andImages:ImagesArray];
        
        self.audioAnimateArray = [NSArray arrayWithObject:_animateView];
    }
    return (AudioAnimateView*)_audioAnimateArray[0];
}

#pragma mark ----- 播放操作相关 -----
//播放暂停
-(void)didClickPlayAndPause:(UIButton*)button
{
//    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    
    BOOL isPlaying = [OnePlayer onePlayer].isPlaying;
    if (isPlaying) {
        [_playPauseBT setImage:[UIImage imageNamed:@"audionews_play_button"] forState:UIControlStateNormal];
        
        [self.diskImgView pauseRotate];
        [[OnePlayer onePlayer]pause];
        
        //暂停cell上动画
        [self.animateView stopAnimate];
    }else{
        
        [_playPauseBT setImage:[UIImage imageNamed:@"audionews_pause_button"] forState:UIControlStateNormal];
        
        [self.diskImgView playRotate];
        [[OnePlayer onePlayer]play];
        
        //开始cell动画
        [self.animateView animate];
    }
}

//设置播放按钮
-(void)setupPlayPauseBTImg
{
    BOOL isPlaying = [OnePlayer onePlayer].isPlaying;
    if (isPlaying) {
        [_playPauseBT setImage:[UIImage imageNamed:@"audionews_pause_button"] forState:UIControlStateNormal];
    }else{
        
        [_playPauseBT setImage:[UIImage imageNamed:@"audionews_play_button"] forState:UIControlStateNormal];
    }
}

//上一曲
-(void)playForward:(UIButton*)button
{
    [self.diskImgView pauseRotate];
    
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    
    //移除上一个cell的动画
    [cell resumeTitlText];
    
    if (_isPlayingIndex > 0) {
        //设置播放动画
        _isPlayingIndex --;
        FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        
        //改变文本及动画
        [newCell showTitleText];
        [self.animateView exchangerSuperViewTo:newCell.contentView];
        
        [self getAudioWithIndex:_isPlayingIndex andByHandle:^(FMPlayingModel*playModle){
            
            //改变封面
            [self.diskImgView changeDiskImageWithUrl:playModle.cover andHandle:^(UIImage *img) {
                if (!img) {
                    if (_coverImg) {
                        [self.diskImgView setDiskImage:_coverImg];
                    }else{
                        [self.diskImgView setDiskImage:COVER_IMG];
                    }
                }
            }];
            
            [self.diskImgView playRotate];
        }];
    }else{
        _isPlayingIndex = _listModelArray.count -1;
        
        FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        
        //改变文本及动画
        [newCell showTitleText];
        [self.animateView exchangerSuperViewTo:newCell.contentView];
        
        [self getAudioWithIndex:_isPlayingIndex andByHandle:^(FMPlayingModel*playModle){
            
            //改变封面
            [self.diskImgView changeDiskImageWithUrl:playModle.cover andHandle:^(UIImage *img) {
                if (!img) {
                    if (_coverImg) {
                        [self.diskImgView setDiskImage:_coverImg];
                    }else{
                        [self.diskImgView setDiskImage:COVER_IMG];
                    }
                }
            }];
            
            [self.diskImgView playRotate];
        }];
    }
    
    [_playPauseBT setImage:[UIImage imageNamed:@"audionews_pause_button"] forState:UIControlStateNormal];
    
    [[OnePlayer onePlayer]play];
}

//下一曲
-(void)playNext:(UIButton*)button
{
    [self.diskImgView pauseRotate];
    
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    
    //移除上一个cell的动画
    [cell resumeTitlText];
    
    if (_isPlayingIndex < (_listModelArray.count-1)) {
        
        _isPlayingIndex ++;
        FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        
        //改变文本及动画
        [newCell showTitleText];
        [self.animateView exchangerSuperViewTo:newCell.contentView];
        
        [self getAudioWithIndex:_isPlayingIndex andByHandle:^(FMPlayingModel * playModle){
            
            //改变封面
            [self.diskImgView changeDiskImageWithUrl:playModle.cover andHandle:^(UIImage *img) {
                if (!img) {
                    if (_coverImg) {
                        [self.diskImgView setDiskImage:_coverImg];
                    }else{
                        [self.diskImgView setDiskImage:COVER_IMG];
                    }
                }
            }];
            
            [self.diskImgView playRotate];
        }];
    }else{
        _isPlayingIndex = 0;
        FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        
        //改变文本及动画
        [newCell showTitleText];
        [self.animateView exchangerSuperViewTo:newCell.contentView];
        
        [self getAudioWithIndex:0 andByHandle:^(FMPlayingModel * playModle){
            
            //改变封面
            [self.diskImgView changeDiskImageWithUrl:playModle.cover andHandle:^(UIImage *img) {
                if (!img) {
                    if (_coverImg) {
                        [self.diskImgView setDiskImage:_coverImg];
                    }else{
                        [self.diskImgView setDiskImage:COVER_IMG];
                    }
                }
            }];
            
            [self.diskImgView playRotate];
        }];
    }
    
    [_playPauseBT setImage:[UIImage imageNamed:@"audionews_pause_button"] forState:UIControlStateNormal];
    
    [[OnePlayer onePlayer]play];
}

#pragma mark ----- 播放开始结束协议 ----

-(void)playBegin
{
    NSLog(@"开始播放了.......");
    [self.diskImgView playRotate];
    [self.animateView animate];
    
    [self setupPlayPauseBTImg];
}

-(void)playFinished
{
    self.progressSlider.value = 0;

/*
    OnePlayer * onePlayer = [OnePlayer onePlayer];

    //不循环直接停止
    [onePlayer removeOnePlayelayer];
    
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    
    [cell removeAnimate];
    [self.animateView removeAnimate];
    [self.diskImgView pauseRotate];
    [self setupPlayPauseBTImg];
    self.isPlayingIndex = -1;
*/
    
/*
    //循环播放
    onePlayer = [onePlayer initWithMyUrl:[OnePlayer onePlayer].playingUrl];
*/
    
/*******继续播放下一曲******/
    
    //恢复之前播放视图的视图
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex++ inSection:0]];
    
    [cell resumeTitlText];

//    if (_isAppAvtive) {
    
        if (_isPlayingIndex>=_listModelArray.count) {
            _isPlayingIndex = 0;
        }
        //播放音乐动画视图
        FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
        
        //改变文本及动画
        [newCell showTitleText];
        [self.animateView exchangerSuperViewTo:newCell.contentView];
        
        
        [self getAudioWithIndex:_isPlayingIndex andByHandle:^(FMPlayingModel * playModle){
            self.playingModel = playModle;
            
            [self setupPlayImageAndTileWith:playModle];
            
            //设置播放按钮样式
            [self setupPlayPauseBTImg];
            [self.diskImgView playRotate];
        }];
//    }else{
//        OnePlayer * onePlayer = [OnePlayer onePlayer];
//        
//        //不循环直接停止
//        [onePlayer removePlayer];
//        
//        [self.animateView exchangerSuperViewTo:nil];
//        [self.diskImgView pauseRotate];
//        [self setupPlayPauseBTImg];
//        self.isPlayingIndex = -1;
//    }
    
}

//返回上一级
-(void)back:(UIButton*)button
{
    if (_block) {
        self.block();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
} 
 
//数据库读取数据时,避免视图推出而没有创建的发生
-(void)setupPlayImageAndTileWith:(FMPlayingModel *)playingModel
{
    NSLog(@"cover ==== %@",playingModel.cover);
    
    //改变封面
    [self.diskImgView resetTransfrom];
    
    [self.diskImgView changeDiskImageWithUrl:playingModel.cover andHandle:^(UIImage *img) {
        if (!img) {
            if (_coverImg) {
                [self.diskImgView setDiskImage:_coverImg];
            }else{
                [self.diskImgView setDiskImage:COVER_IMG];
            }
        }
    }];
    
    _titleLable.text = playingModel.source;
}

#pragma mark ------tableview delegate-------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listModelArray) {
        return _listModelArray.count;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SELF_WIDTH*1.0/6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMlistTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    if (!cell) {
        cell = [[FMlistTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"listCell"];
    }
    
    if (_listModelArray) {
        
        FMListModel * model = _listModelArray[indexPath.row];
        cell.titleLable.text = model.title;
        cell.timeLable.text = model.ptime;
        
        //设置下载图片
        if ([[PersistManger defoutManger]isDownloadWith:model.docid]) {
            [cell setupDownloadBTImageWithState:DownloadDone];
        }else{
            //沙盒字典粗出下载状态,是否正在下载
            BOOL isDownloading = [[PersistManger defoutManger]isDownloadingWith:[NSString stringWithFormat:@"%@downloading",model.docid]];
            if (!isDownloading) {
                [cell setupDownloadBTImageWithState:DownloadAvilable];
            }else{
                [cell setupDownloadBTImageWithState:Downloading];
            }
        }
        
        //定义下载block
        cell.downloadDataBlock = ^{
            [self if_downloadDataAtIndex:indexPath.row];
        };
        
         NSLog(@"cellcenter == %.2f",cell.center.y);
        
        if (indexPath.row == _isPlayingIndex) {
            [cell showTitleText];
            [self.animateView exchangerSuperViewTo:cell.contentView];
            
            NSLog(@"animatecenter == %.2f   cellcenter == %.2f",self.animateView.center.y,cell.contentView.center.y);
            
            //处理滚动tableview时cell重用赋值后音乐动画处于暂停状态
            if ([[OnePlayer onePlayer]isPlaying]) {
                [self.animateView animate];
            }
        }else{
            [cell resumeTitlTextRightNow];
        }
    }
    return cell;
}

#pragma mark --------下载数据-------

-(void)if_downloadDataAtIndex:(NSInteger)index
{
    FMListModel * model = (FMListModel*)_listModelArray[index];
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    BOOL isDownloading = [[PersistManger defoutManger]isDownloadingWith:[NSString stringWithFormat:@"%@downloading",model.docid]];
    
    if (!isDownloading) {
        [self downloadDataAtIndex:index];
        [cell setupDownloadBTImageWithState:Downloading];
    }else{
        //取消下载
        NSURLSessionDownload * sessionDownOperation = (NSURLSessionDownload*)[self.downloadObjectDic objectForKey:@(index)];
        
        [sessionDownOperation cancellResumableTask];
        [cell setupDownloadBTImageWithState:DownloadAvilable];
        [[PersistManger defoutManger]deleteDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",model.docid]];
    }
}

-(void)downloadDataAtIndex:(NSInteger)index
{
/*
    if (index == _isPlayingIndex) {
        
        NSURLSessionDownload * sessionDownOperation = (NSURLSessionDownload*)[self.downloadObjectDic objectForKey:@(index)];
        if (!sessionDownOperation) {
            //创建下载工具对象
            sessionDownOperation = [NSURLSessionDownload urlSessionResumableTaskWithUrl:[NSURL URLWithString:_playingModel.url_mp4] andHandle:^{
                //开始下载时的操作
                
                [[PersistManger defoutManger]setDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",_playingModel.docid]];
            }];
            
            //将下载工具对象存入字典
            [self.downloadObjectDic setObject:sessionDownOperation forKey:@(index)];
        }else{
            [sessionDownOperation resumableTaskWithUrl:[NSURL URLWithString:_playingModel.url_mp4] andHandle:^{
                [[PersistManger defoutManger]setDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",_playingModel.docid]];
                NSLog(@"downloadIndex ================ %d",(int)index);
                NSLog(@"mp4Url-playingmodel ---------- %@",_playingModel.url_mp4);
            }];
        }
        
        //执行下载完成操作
        [sessionDownOperation successDownloadWithHandle:^(NSURL *location) {
            if (location) {
                FMPlayingModel * playingModel = _playingModel;
                
                //存储下载的数据
                [self writeDataWithUrl:location toPath:[NSString stringWithFormat:@"%@.mp3",playingModel.docid]];
                
                //存储下载数据
                NSArray *array = [DataBaseHandle getDataArrayWithTitleid:DownLoadKey];
                if (array) {
                    NSMutableArray * dataArray = [array mutableCopy];
                    [dataArray addObject:playingModel];
                    [DataBaseHandle insertDBWWithArra:dataArray byID:DownLoadKey];
                }else{
                    NSMutableArray * dataArray = [@[] mutableCopy];
                    [dataArray addObject:playingModel];
                    [DataBaseHandle insertDBWWithArra:dataArray byID:DownLoadKey];
                }
                
                //设置下载完成标记
                [[PersistManger defoutManger]setDownloadMarkWith:playingModel.docid];
                
                //取消正在下载标记
                [[PersistManger defoutManger]deleteDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",playingModel.docid]];
                
                FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
                NSArray * visibleIndex = [self.listTableView indexPathsForVisibleRows];
                if ([visibleIndex containsObject:[NSIndexPath indexPathForRow:index inSection:0]]) {
                    [cell setupDownloadBTImageWithState:DownloadDone];
                }
            }
        }];
    }else{
        
    }
*/
    
    FMListModel * listModel = [_listModelArray objectAtIndex:index];
    
    NSLog(@"index ==== %d,model ===== %@",(int)index,listModel.docid);
    
    [PersistManger getFMPlayingDataWithUrl:listModel.docid andByHandle:^(id model) {
        FMPlayingModel * playModel = model;
        NSLog(@"downloadIndex ================ %d,%@,%@",(int)index,playModel.docid,playModel);
        NSLog(@"mp4Url --model --------------- %@",playModel.url_mp4);
        
        NSURLSessionDownload * sessionDownOperation = (NSURLSessionDownload*)[self.downloadObjectDic objectForKey:@(index)];
        if (!sessionDownOperation) {
            //创建下载工具对象
            sessionDownOperation = [NSURLSessionDownload urlSessionResumableTaskWithUrl:[NSURL URLWithString:playModel.url_mp4] andHandle:^{
                //开始下载时的操作
                
                [[PersistManger defoutManger]setDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",playModel.docid]];
            }];
            
            [self.downloadObjectDic setObject:sessionDownOperation forKey:@(index)];
        }else{
            [sessionDownOperation resumableTaskWithUrl:[NSURL URLWithString:playModel.url_mp4] andHandle:^{
                [[PersistManger defoutManger]setDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",playModel.docid]];
            }];
        }
        
        //执行下载完成操作
        [sessionDownOperation successDownloadWithHandle:^(NSURL *location) {
            if (location) {
                //存储下载的数据
                [self writeDataWithUrl:location toPath:[NSString stringWithFormat:@"%@.mp3",playModel.docid]];
                
                NSLog(@"下载完成docid ============== %d,%@,%@",(int)index,playModel.docid,playModel);
                
                //存储下载数据
                NSArray *array = [DataBaseHandle getDataArrayWithTitleid:DownLoadKey];
                if (array) {
                    NSMutableArray * dataArray = [array mutableCopy];
                    [dataArray addObject:playModel];
                    [DataBaseHandle insertDBWWithArra:dataArray byID:DownLoadKey];
                }else{
                    NSMutableArray * dataArray = [@[] mutableCopy];
                    [dataArray addObject:playModel];
                    [DataBaseHandle insertDBWWithArra:dataArray byID:DownLoadKey];
                }
                
                //设置下载完成标记
                [[PersistManger defoutManger]setDownloadMarkWith:playModel.docid];
                
                //取消正在下载标记
                [[PersistManger defoutManger]deleteDownloadingMarkWith:[NSString stringWithFormat:@"%@downloading",playModel.docid]];
                
                FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
                NSArray * visibleIndex = [self.listTableView indexPathsForVisibleRows];
                if ([visibleIndex containsObject:[NSIndexPath indexPathForRow:index inSection:0]]) {
                    [cell setupDownloadBTImageWithState:DownloadDone];
                }
            }
        }];
    }];

}

//存储下载的数据在制定的路径
-(void)writeDataWithUrl:(NSURL*)location toPath:(NSString*)path
{
    @synchronized(self){
        NSString * docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString * dataPath = [docuPath stringByAppendingPathComponent:path];
        
        NSLog(@"mp3Path ====---------==== %@",dataPath);
        
        NSMutableData * data = [NSMutableData dataWithContentsOfURL:location];;
        if (!data) {
            return;
        }
        [data writeToFile:dataPath atomically:YES];
    }
}

//点击cell协议
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断网络状态
    [[PersistManger defoutManger]judgeNetStatusAndAlert];
    
    //先暂停palyer
    [[OnePlayer onePlayer]pause];
    
    //恢复之前播放视图的视图
    FMlistTableViewCell * cell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
//    NSArray * cellArray = [self.listTableView visibleCells];
//    if ([cellArray containsObject:cell]) {
//        [cell removeAnimate];
//    }
    
    [cell resumeTitlText];
    [self.diskImgView pauseRotate];
    [self setupPlayPauseBTImg];
    
    //播放音乐动画视图
    FMlistTableViewCell * newCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:indexPath];
    [newCell showTitleText];
    [self.animateView exchangerSuperViewTo:newCell.contentView];
    
    NSLog(@"animatecenter == %.2f   cellcenter == %.2f",self.animateView.center.y,newCell.contentView.center.y);
    
    _isPlayingIndex = indexPath.row;
    
    __weak FMPlayListViewController * sself = self;
    
    [self getAudioWithIndex:indexPath.row andByHandle:^(FMPlayingModel * playModle){
        sself.playingModel = playModle;
        
        [sself setupPlayImageAndTileWith:playModle];
        
        //设置播放按钮样式
        [sself setupPlayPauseBTImg];
    }];
    
    if ([OnePlayer onePlayer].isPlyed) {
        [self showPlayingTime];
    }
    
//    [self performSelector:@selector(deselectCellForRow:) withObject:indexPath afterDelay:0.05];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)deselectCellForRow:(NSIndexPath*)indexpath
{
    [self.listTableView deselectRowAtIndexPath:indexpath animated:YES];
}

#pragma mark-----ScrollViewDelegate-----
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    FMlistTableViewCell * currentCell = (FMlistTableViewCell*)[self.listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayingIndex inSection:0]];
    NSArray * cellArray = [self.listTableView visibleCells];
    if (![cellArray containsObject:currentCell]) {
        [self.animateView exchangerSuperViewTo:nil];
    }
}

//获取播放音频文件
-(void)getAudioWithIndex:(NSInteger)index andByHandle:(AudioBlock)handle
{
    FMListModel * model = _listModelArray[index];
    
    [PersistManger getFMPlayingDataWithUrl:model.docid andByHandle:^(id model) {
        FMPlayingModel * playModel = (FMPlayingModel*)model;
        
        NSLog(@"docid ====== %@",playModel.docid);
        NSLog(@"cover =----- %@",playModel.cover);
        
//        OnePlayer * onePlayer = [[OnePlayer onePlayer]initWithMyUrl:[NSURL URLWithString:playModel.url_mp4] addToView:[self.view superview]];
        
        OnePlayer * onePlayer = [[OnePlayer onePlayer]initWithMyUrl:[NSURL URLWithString:playModel.url_mp4]];
        
        NSLog(@"mp4url ======== %@",playModel.url_mp4);
        
        if (!onePlayer.isPlaying) {
            [onePlayer play];
        }
        
        if (handle) {
            handle(playModel);
        }
    }];
}

//请求加载disk封面,这个方法被取消了，因为加载会消耗时间
-(void)changeDiskCoverWithIndex:(NSInteger)index
{
    __weak FMPlayListViewController * sself = self;
    
    FMListModel * model = _listModelArray[index];
    
    [PersistManger getFMPlayingDataWithUrl:model.docid andByHandle:^(id model) {
        FMPlayingModel * playModel = (FMPlayingModel*)model;
        
        [sself.diskImgView changeDiskImageWithUrl:playModel.cover andHandle:^(UIImage *img) {
            
        }];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //设置标记，用于记录当前页面的信息，最后从提示window返回时用于加载。
    [[OnePlayer onePlayer]setMask:[NSString stringWithFormat:@"%d",(int)_isPlayingIndex] forKey:kIndex];
    [[OnePlayer onePlayer]setMask:[self.diskImgView diskImage] forKey:kDiskImage];
    [[OnePlayer onePlayer]setMask:self.coverImg forKey:kDiskCover];
    if ([OnePlayer onePlayer].isPlaying) {
        [PersistManger showPlayingSmallWindowWith:_playingModel name:self.cateName title:_playingModel.title dbKey:self.dbDocidKey];
    }
    
//    _playingModel = nil;
    
#pragma mark ----- 当页面pop之后，并不是立即dealloc，所以nstimer必须手动停止销毁
    
    [self.animateView removeAnimate];
    
    [self.diskImgView finishRotate];
    
    /*取消远程事件*/
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PersistManger hidenSmallWindow];
    
    if (![[OnePlayer onePlayer]isPlaying]) {
        [_diskImgView pauseRotate];
        [self.animateView resetAnimateAndPause];
    }
    
    /*注册远程事件*/
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    NSLog(@"视图将要出现..........");
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
                [self didClickPlayAndPause:nil];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self didClickPlayAndPause:nil];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNext:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playForward:nil];
                break;
            default:
                break;
        }
        
        NSLog(@"enentSubtype ===== %ld",(long)event.subtype);
    }
}

#pragma mark ----手势协议----

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    //    self.navigationController.navigationBar.alpha = 1;
//    
//    return YES;
//}

-(void)dealloc
{
    
}

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController *)fromVC
//                                                 toViewController:(UIViewController *)toVC
//{
//    if (operation == UINavigationControllerOperationPop) {
//        if (self.popAnimator == nil) {
//            self.popAnimator = [WQPopAnimator new];
//        }
//        return self.popAnimator;
//    }
//    
//    return nil;
//}
//
//- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
//                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
//{
//    return self.popInteractionController;
//}
//
//#pragma mark -
//
//- (void)enablePanToPopForNavigationController:(UINavigationController *)navigationController
//{
//    UIScreenEdgePanGestureRecognizer *left2rightSwipe = [[UIScreenEdgePanGestureRecognizer alloc]
//                                                         initWithTarget:self
//                                                         action:@selector(didPanToPop:)];
//    //[left2rightSwipe setDelegate:self];
//    [left2rightSwipe setEdges:UIRectEdgeLeft];
//    [navigationController.view addGestureRecognizer:left2rightSwipe];
//    
//    self.popAnimator = [WQPopAnimator new];
//    self.supportPan2Pop = YES;
//    
//    NSLog(@".....");
//}
//
//- (void)didPanToPop:(UIPanGestureRecognizer *)panGesture
//{
//    if (!self.supportPan2Pop) return ;
//    
//    UIView *view = self.navigationController.view;
//    
//    if (panGesture.state == UIGestureRecognizerStateBegan) {
//        self.popInteractionController = [UIPercentDrivenInteractiveTransition new];
//        [self.navigationController popViewControllerAnimated:YES];
//    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [panGesture translationInView:view];
//        CGFloat d = fabs(translation.x / CGRectGetWidth(view.bounds));
//        [self.popInteractionController updateInteractiveTransition:d];
//    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
//        if ([panGesture velocityInView:view].x > 0) {
//            [self.popInteractionController finishInteractiveTransition];
//        } else {
//            [self.popInteractionController cancelInteractiveTransition];
//        }
//        self.popInteractionController = nil;
//    }
//    NSLog(@".....");
//}

/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint beginPoint = [touch locationInView:self.view];
 
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"开始");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"改变了");
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"结束了");
    }
    
    NSLog(@"point == %.2f",beginPoint.x);
//
//    NSLog(@"status ===== %ld",gestureRecognizer.state);
//    
//    NSLog(@"biibb");
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    self.navigationController.navigationBarHidden = NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"滑动中...");
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.listTableView];
    
//    NSLog(@"point === %.2f",_beginPoint.x);
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"移动中..");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

*/
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
