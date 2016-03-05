//
//  VideoViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "VideoViewController.h"
#import "NSString+StringHeight.h"
#import "FMPlayListViewController.h"
#import "DataBaseHandle.h"


#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height


#define CELL_HEIGHT SELF_WIDTH*0.77


@interface VideoViewController ()

{
    PlayWindowStyle playWindow;
    
    id _playBackTimeOserver;
}
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;
@property (nonatomic,assign) BOOL isPlaying;           //视频播放状态
@property (nonatomic,assign) BOOL isPlayed;            //播放完成状态
@property (nonatomic,assign) NSInteger isPlayIndex;    //正在播放的cell的下标位置
@property (nonatomic,strong) UIView * playView;
//@property (nonatomic,strong) UIImageView * orginImgView;
@property (nonatomic,assign) CGRect orginFrame;
@property (nonatomic,strong) UIImage * coverImg;       //获取视频封面图片
@property (nonatomic,strong) UIProgressView * playPG;        //获取cell的播放进度条,用于播放完成后取消开始按钮隐藏
@property (nonatomic,assign) CGFloat totalTime;
@property (nonatomic,assign) CGFloat currentTime;
@property (nonatomic,copy) void(^block)();
@property (nonatomic,strong) OnePlayer * onePlayer;
@property (nonatomic,strong) UIImageView * playImgView;
@property (nonatomic,assign) int pageCount;
@property (nonatomic,strong) NSTimer * outTimer;



@end

@implementation VideoViewController

-(instancetype)init
{
    if ([super init]) {
        //        [PersistManger defoutManger].showDelegate = self;
        self.pageCount = 1;
        
        //注册程序进入后台通知，取消视播放
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeInActiveStopVideo) name:kBecomeInActive object:nil];
        
        //注册回到前台通知，继续播放视频或者做其他操作
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeActiveGoonPlay) name:kBecomeActive object:nil];
    }
    return self;
}

-(void)appBecomeInActiveStopVideo
{
    if ([[OnePlayer onePlayer]isPlaying]) {
        if ([[OnePlayer onePlayer].playerLayer superlayer]) {
            [[OnePlayer onePlayer]pause];
/*
            VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]];
            cell.playStatus = Pause;
            [cell setupPlayAndPauseBT];
            [cell showPlayButton];
*/
        }
    }
}

-(void)appBecomeActiveGoonPlay
{
    if (![[OnePlayer onePlayer]isPlaying]) {
        if ([[OnePlayer onePlayer].playerLayer superlayer]) {
            [[OnePlayer onePlayer]play];
            
            [self.tableView reloadData];
        }
    }
}

/*********
 -(void)showPlayingAudioAndHidenSmallWindow
 {
 [[OnePlayer onePlayer]playAudioFromController:self];
 }
 *********/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NC_HEIGHT, SELF_WIDTH, SELF_HEIGHT-(TABBAR_HEIGHT +NC_HEIGHT)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSLog(@"height === %.2f",NC_HEIGHT);
    
    [self.view addSubview:_tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
/*
     BOOL nibRegistered = NO;
     if (!nibRegistered) {
     UINib * nib = [UINib nibWithNibName:NSStringFromClass([VideoTableViewCell class]) bundle:nil];
     
     [self.tableView registerNib:nib forCellReuseIdentifier:@"videoCell"];
     
     nibRegistered = YES;
     }
*/
    
    [self.tableView registerClass:[VideoTableViewCell class] forCellReuseIdentifier:@"videoCell"];
    
    //下拉刷新
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        if ([OnePlayer onePlayer].isPlyed && ![[OnePlayer onePlayer].playerLayer superlayer]) {
            [PersistManger getModelWithUrl:[NSURL URLWithString:VIDEO_URL(1)] andByHandle:^(NSMutableArray *arr) {
                if (self.dataArray.count != 0) {
                    [_dataArray removeAllObjects];
                }
                _isPlayIndex = -1;
                _coverImg = nil;
                _playImgView = nil;
                [self.dataArray addObjectsFromArray:arr];
                _pageCount = 1;
                
                //数据库存储
                [DataBaseHandle insertDBWWithArra:_dataArray byID:NSStringFromClass([self class])];
                
                [self.tableView.header endRefreshing];
                
                [self.tableView reloadData];
                
                if (_outTimer) {
                    [_outTimer invalidate];
                    _outTimer = nil;
                }
            }];
        }else{
            [self.tableView.header endRefreshing];
            if (_outTimer) {
                [_outTimer invalidate];
                _outTimer = nil;
            }
        }
    }];
    
    //从数据库读取数据
    NSArray * array = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
    if (array.count != 0) {
        self.dataArray = [array mutableCopy];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];

    }else{
        self.dataArray = [@[] mutableCopy];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    
    //初始化isPlayIndex，防止默认是0
    self.isPlayIndex = -1;
    _isPlayed = YES;
    _isPlaying = NO;
    
    //设置导航栏视图
    [[PersistManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@"title1"] andBGImg:[UIImage imageNamed:NC_IMG]];
    
    //上拉加载
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self refreshData];
    }];
}

-(void)refreshData
{
    [PersistManger getModelWithUrl:[NSURL URLWithString:VIDEO_URL(++ _pageCount)] andByHandle:^(NSMutableArray *arr) {
        if (_pageCount == 2) {
//            [arr removeObjectAtIndex:0];
            [arr removeObjectAtIndex:0];
        }
        [self.dataArray addObjectsFromArray:arr];
        [self.tableView reloadData];
        
        
        [self.tableView.footer setState:MJRefreshStateIdle];

        //数据库存储
//        [DataBaseHandle insertDBWWithArra:_dataArray byID:NSStringFromClass([self class])];
    }];
}

-(void)showNetWorkBad
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您当前的网络不给力，请重新刷新！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    if (_outTimer) {
        [_outTimer invalidate];
        _outTimer = nil;
    }
    
    [self.tableView.header endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"dataArrayCount ====== %d",(int)_dataArray.count);
    
    if (_dataArray.count != 0) {
        return _dataArray.count;
    }else{
        return 0;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoTableViewCell * cell = (VideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"videoCell"];
/*
     if (!cell) {
     NSString * name = NSStringFromClass([VideoTableViewCell class]);
     cell = [[[NSBundle mainBundle]loadNibNamed:name owner:self options:nil] objectAtIndex:0];
     }
*/
    
    //取消点击颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_dataArray.count != 0) {
        cell.videoModel = _dataArray[indexPath.row];
        
        //判断cell重用时的播放状态设置背景图片
        if (_isPlayIndex == indexPath.row) {
            if (!_isPlayed) {
                if (_isPlaying) {
                    cell.playStatus = Playing;
                }else{
                    cell.playStatus = Pause;
                }
                
                cell.videoImgView.image = nil;
                cell.videoImgView.backgroundColor = [UIColor blackColor];
                 
                //布局cell的控制视图
                [cell setupPlayStatusControllView];
                [cell hidePlayButton];
            }else{
                [cell showPlayButton];
                [cell hideControllViewRightNow];
                cell.videoImgView.image = _coverImg;
            } 
        }else {
            if (_isPlaying) {
                cell.playStatus = Playing;
            }else{
                cell.playStatus = Pause;
            }
            
            [cell showPlayButton];
            [cell setupPlayStatusControllView];
            [cell hideControllView];
            
            NSLog(@"indexpath ----- %d",(int)indexPath.row);
        }
    }
    
    /*
     *视频点击block的声明
     */
    __weak VideoViewController * sself = self;
    __weak VideoTableViewCell * c_cell = cell;
    cell.videoBlock = ^(UIImageView * imgView,UISlider * pg,NSString * urlStr){
        
        VideoTableViewCell * videoCell = (VideoTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]];
        [videoCell showPlayButton];
        
//        //播放时改变背景图
//        if (_playImgView) {
//            _playImgView.image = _coverImg;
//        }
        if ([[tableView visibleCells]containsObject:videoCell]) {
            videoCell.videoImgView.image = _coverImg;
        }
//        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        sself.playImgView = imgView;
        sself.coverImg = imgView.image;
        imgView.image = nil;
        
        //记录视频播放view的位置
        sself.isPlayIndex = indexPath.row;    //这里要先获取视频播放的indexpath
        
        sself.onePlayer = [[OnePlayer onePlayer]initWithMyUrl:[NSURL URLWithString:urlStr] addToView:imgView];
        //显示进度占位
        [[PersistManger defoutManger]showProgressHUDToView:imgView overTimeByHandle:^{
            self.isPlayed = YES;
            self.isPlaying = NO;
            self.isPlayIndex = -1;
            [[OnePlayer onePlayer]removeOnePlayelayer];
            [[OnePlayer onePlayer]removePlayer];
            
            [self.tableView reloadData];
        }];
        
        //设置视频代理
        sself.onePlayer.delegate = sself;
        
        //隐藏音频小视窗window
        [PersistManger hidenSmallWindow];
        
        
        //如果小窗口视频正在播放，移除小窗口
        [sself.playView removeFromSuperview];
        
        _isPlaying = YES;
        _isPlayed = NO;
        
        [_onePlayer start];
        [c_cell hidePlayButton];
        
        if (sself.block) {
            sself.block();
        }
        
        //移除播放音频的标记
        [_onePlayer.maskDic removeAllObjects];
        
        //提示网络
        [[PersistManger defoutManger] judgeNetStatusAndAlert];
        
//        [self.tableView reloadData];
    };
    
    /*
     *视频点击开始暂停block的声明
    */
    cell.playBlock = ^(PlayStatus status){
        if (!_isPlayed) {
            switch (status) {
                case 0:
                    [_onePlayer play];
                    _isPlaying = YES;
                    
                    break;
                case 1:
                    [_onePlayer pause];
                    _isPlaying = NO;
                    
                    break;
                default:
                    break;
            }
        }
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了");
    VideoTableViewCell * cell = (VideoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == _isPlayIndex) {
        if (cell.controllView.userInteractionEnabled == NO && _isPlayed == NO) {
            [cell showCotrollView];
            [cell recordClickTimes];
        }else{
            [cell hideControllView];
        }
    }
    
    self.block = ^{
        [cell hideControllViewRightNow];
    };
}



#pragma mark ---- 视频播放完成协议实现 ----

-(void)playBegin
{
    //隐藏占位进度
    [[PersistManger defoutManger]hideProgressHUD];
}

-(void)playFinished
{
    NSLog(@"视频播放完成.");
    
    //设置播放完成
    self.isPlaying = NO;
    self.isPlayed = YES;
    
    [_onePlayer removeOnePlayelayer];
    
    VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]];
    if ([[self.tableView indexPathsForVisibleRows]containsObject:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]]) {
        cell.videoImgView.image = _coverImg;
        //显现播放按钮
        [cell showPlayButton];
        [cell hideControllViewRightNow];
    }
    
    _coverImg = nil;
    _isPlayIndex = -1;
    
    //移除小视窗
    if (_playView) {
        [_playView removeFromSuperview];
    }
}

-(void)playFailed
{
    [[PersistManger defoutManger]hideProgressHUD];
    
    VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]];
    
    cell.videoImgView.image = _coverImg;
    
    [cell hideControllViewRightNow];
    
    _isPlayIndex = -1;
}


#pragma mark ---- 视频窗口滚动出边界后窗口最小化 ----

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_dataArray.count != 0) {
        //解决cell重用时重复显示
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_isPlayIndex inSection:0];
        
        VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSArray * cellArray = [self.tableView visibleCells];
        
        BOOL changeFlag = [cellArray containsObject:cell];
        
        //判断条件调整播放窗口的位置
        if (!_isPlayed) {
            [cell hideControllViewRightNow];
            
            if (_isPlaying) {
//                [cell hideControllViewRightNow];
                
                if (changeFlag) {
                    [self changePlayVideoWindowWithPlayWindowStyle:PlayWindowOrgin];
                }else{
                    [self changePlayVideoWindowWithPlayWindowStyle:PlayWindowSmall];
                }
            }else {
                if (changeFlag) {
#warning ------ AVPlayerLayer具有可以重复添加的特性，即，一个layer可以在多个layer上添加 ------
                    [_onePlayer changeToView:cell.videoImgView];
                    
                    [cell hidePlayButton];
                }else {
                    //滚动过程中，如果当前显示的cell不是播放的index，为了避免cell重用显示在其他的index，将layer移除。
                    [_onePlayer.playerLayer removeFromSuperlayer];
//                    [cell hideControllViewRightNow];
                }
            }
            if (changeFlag) {
                [cell showPlayProgress];
            }
        }
    }
}

-(void)changePlayVideoWindowWithPlayWindowStyle:(PlayWindowStyle)style
{
    
    CGFloat tabBarH = self.tabBarController.tabBar.frame.size.height;
    
    if (!_playView) {
        self.playView = [[UIView alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH*2/5 - 10, SELF_HEIGHT - SELF_WIDTH*3/10 - 10 - tabBarH, SELF_WIDTH*2/5, SELF_WIDTH*3/10)];
        _playView.backgroundColor = [UIColor darkGrayColor];
        _playView.layer.borderColor = [UIColor whiteColor].CGColor;
        _playView.layer.borderWidth = 1.5;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resumeOrginVideoWindow:)];
        [_playView addGestureRecognizer:tap];
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_isPlayIndex inSection:0];
    
    VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    switch (style) {
        case 0:
            [[self.view superview] addSubview:_playView];
            
            if (_onePlayer) {
                [_onePlayer changeToView:_playView];
            }
            
            break;
        case 1:
            [self.playView removeFromSuperview];
            
            if (_onePlayer) {
                [_onePlayer changeToView:cell.videoImgView];
            }
            
            break;
        default:
            break;
    }
}

//点击小播放窗口恢复原窗口播放
-(void)resumeOrginVideoWindow:(UIGestureRecognizer*)gesture
{
    [self changePlayVideoWindowWithPlayWindowStyle:PlayWindowOrgin];
    
    if (_isPlayIndex == 0){
        [self.tableView setContentOffset:CGPointMake(0, -STATUS_HEIGHT) animated:YES];
    }else if (_isPlayIndex == self.dataArray.count - 1){
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height) animated:YES];
    }else{
        [self.tableView setContentOffset:CGPointMake(0, _isPlayIndex * CELL_HEIGHT - (SELF_HEIGHT/2 - CELL_HEIGHT/2 - STATUS_HEIGHT)) animated:YES];
    }
}

#pragma mark ----退出当前视图后，移除player----
-(void)viewWillDisappear:(BOOL)animated
{
    [self.playerLayer removeFromSuperlayer];
    
    if (_playView) {
        [_playView removeFromSuperview];
    }
    
    if ([_onePlayer.playerLayer superlayer]) {
        [_onePlayer removeOnePlayelayer];
        [_onePlayer removePlayer];
    }
    
    //显现播放按钮
    VideoTableViewCell * cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_isPlayIndex inSection:0]];
    if ([[self.tableView visibleCells]containsObject:cell]) {
        [cell showPlayButton];
        cell.videoImgView.image = _coverImg;
    }
    
    _isPlayIndex = -1;
    _isPlayed = YES;
    _isPlaying = NO;
    
//    if (_playImgView) {
//        _playImgView.image = _coverImg;
//    }
    _coverImg = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPlayingAudioVC:) name:BackAudioMark object:nil];
}

-(void)pushPlayingAudioVC:(NSNotification*)notification
{
    [[OnePlayer onePlayer]playAudioFromController:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


/*******************************/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
