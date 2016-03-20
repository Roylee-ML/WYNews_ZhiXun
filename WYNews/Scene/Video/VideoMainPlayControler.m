//
//  VideoMainPlayControler.m
//  WYNews
//
//  Created by Roy lee on 16/3/15.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "VideoMainPlayControler.h"
#import "UserVideoCell.h"
#import "VideoCellPlayVM.h"
#import "ShareManger.h"
#import "NSObject+UIAlert.h"
#import "VideoSortHeaderBar.h"
#import "VideoSortPlayController.h"
#import "OnePlayer.h"
#import "SmallWinView.h"
#import "FullScreenViewController.h"

#define STATUS_HEIGHT  [UIApplication sharedApplication].statusBarFrame.size.height
#define NAV_HEIGHT     self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT  self.tabBarController.tabBar.frame.size.height

static NSString * const VideoDataFromDBKey = @"VideoDataFromDBKey";
static void * VideoPlayToEndContext        = &VideoPlayToEndContext;
static void * VideoPlayDidChangeContext    = &VideoPlayDidChangeContext;

@interface VideoMainPlayControler ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) VideoCellPlayVM * videoCellPlayVM;
@property (nonatomic, strong) MHomeVideoList * mVideoList;
@property (nonatomic, strong) VideoSortHeaderBar * headerSortBar;
@property (nonatomic, strong) SmallWinView * smallView;
@property (nonatomic, assign) CGRect playingCellRect;
@property (nonatomic, assign) CGFloat minPlayViewTopSpace;

@end

@implementation VideoMainPlayControler

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    [self initData];
    
    // 设置导航栏视图
    [[ShareManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@"title1"] andBGImg:[UIImage imageNamed:NC_IMG]];
    // FM播放的时候，点击顶部播放提示状态栏进入FM播放页面
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPlayingAudioVC:) name:BackAudioMark object:nil];
    // 当前播放视频发生改变
    [self.videoCellPlayVM.playerManger addObserver:self forKeyPath:@"track" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:VideoPlayDidChangeContext];
}

- (void)initViews {
    self.tableView = ({
        UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tableView.backgroundColor = [UIColor colorWithHex:@"f2f2f2"];
        tableView.top = NAV_HEIGHT;
        tableView.height = kScreenHeight - (TABBAR_HEIGHT + NAV_HEIGHT);
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:UserVideoCell.class forCellReuseIdentifier:kUserVideoCellIdfy_Normal];
        @weakify(self);
        tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self reloadData];
        }];
        tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self requestDataWith:self.mVideoList];
        }];
        [self.view addSubview:tableView];
        // header
        tableView.tableHeaderView = self.headerSortBar = [VideoSortHeaderBar new];
        [self.headerSortBar setHeaderSortBarDidSelectedItemBlock:^(MVideoSort * sort, NSInteger index) {
            @strongify(self);
            [ShareManger defoutManger].currentVideoSid = sort.sort_id;
            VideoSortPlayController * sortVC = [[VideoSortPlayController alloc]initWithSortID:sort.sort_id];
            sortVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sortVC animated:YES];
        }];
        tableView;
    });
}

- (void)initData {
    //从数据库读取数据
    NSDictionary * dic = [DataBaseHandle getDataDictionaryWithTitleid:VideoDataFromDBKey];
    NSArray * videoList = dic[@"videoList"];
    NSArray * sortList = dic[@"sortList"];
    if (videoList.count != 0) {
        self.mVideoList = [[MHomeVideoList alloc]initWithVideoList:[videoList mutableCopy]];
        self.mVideoList.videoSortList = sortList;
        [self.headerSortBar setSorts:sortList];
        self.tableView.tableHeaderView = self.headerSortBar;
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }else{
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    // view model init
    VideoCellPlayVMSource * vmSource = [[VideoCellPlayVMSource alloc]initWithContainerController:self tableView:self.tableView videoSource:self.mVideoList.videoList];
    self.videoCellPlayVM = [[VideoCellPlayVM alloc]initWithVideoVMSource:vmSource];
}

- (void)reloadData {
    MHomeVideoList * videoList = [[MHomeVideoList alloc]initWithVideoList:[@[] mutableCopy]];
    [self requestDataWith:videoList];
}

- (void)requestDataWith:(MHomeVideoList *)videoList {
    int currentPage = videoList.currentPage;
    [ShareManger getHomeVideoListWithPage:currentPage mVideoList:videoList complicationHandle:^(MHomeVideoList * _videoList) {
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (videoList.videoList.count > 0) {
            self.mVideoList = _videoList;
            //数据库存储
            NSMutableDictionary * db_dic = [NSMutableDictionary dictionaryWithCapacity:2];
            if (_mVideoList.videoSortList.count > 0) {
                db_dic[@"sortList"] = _mVideoList.videoSortList;
            }
            db_dic[@"videoList"] = _mVideoList.videoList;
            [DataBaseHandle insertDBWWithDictionary:db_dic byID:VideoDataFromDBKey];
            // vm data update
            self.videoCellPlayVM.videoVMSource.videoSource = self.mVideoList.videoList;
            // refresh UI
            if (currentPage == 0) {
                [self.headerSortBar setSorts:_mVideoList.videoSortList];
                self.tableView.tableHeaderView = self.headerSortBar;
            }
            [self.tableView reloadData];
        }
    } errorHandle:^(NSError *error) {
        [self.tableView.header endRefreshing];
        [self showAlertWithTitle:@"提示" message:@"您当前的网络不给力，请重新刷新！" delegate:self completionHandle:nil buttonTitles:@"确定",nil];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mVideoList.videoList.count;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UserVideoCell cellHeightWith:_mVideoList.videoList[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:kUserVideoCellIdfy_Normal];
    cell.delegate = self.videoCellPlayVM;
    MVideo * video = _mVideoList.videoList[indexPath.row];
    [cell configCellWith:video];
    // first play view top space
    if (indexPath.row == 0) {
        self.minPlayViewTopSpace = [tableView convertPoint:cell.playView.frame.origin fromView:cell.playView.superview].y;
        NSLog(@"第一个视频窗口距离顶部的距离是：%.2f",_minPlayViewTopSpace);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.videoCellPlayVM didSelectRowAtIndexPath:indexPath];
}

#pragma mark - ScrollView M
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.videoCellPlayVM.playerManger.isPlayingVideo) {
        UserVideoCell * cell = (UserVideoCell *)self.videoCellPlayVM.playingCell;
        CGRect playerFrame = [self.view convertRect:cell.playView.frame fromView:cell.playView.superview];
        CGFloat minY = CGRectGetMinY(playerFrame);
        CGFloat maxY = CGRectGetMaxY(playerFrame);
        if (maxY < 64 || minY > (kScreenHeight - 49)) {
            [self changePlayerToSmallWindow];
        }else {
            if (_smallView) {
                [self.smallView removeFromSuperview];
                [self setSmallView:nil];
                [self.videoCellPlayVM.playerManger setCurrentPlayerView:cell.playView];
            }
        }
    }
}

- (void)changePlayerToSmallWindow {
    if (!_smallView) {
        self.smallView = [SmallWinView new];
        _smallView.backgroundColor = [UIColor blackColor];
        _smallView.size = CGSizeMake(kScreenWidth *2/5, kScreenWidth *3/10);
        _smallView.right = kScreenWidth - 10;
        _smallView.bottom = kScreenHeight - (TABBAR_HEIGHT + 10);
        [self.view addSubview:_smallView];
        [self.videoCellPlayVM.playerManger setCurrentPlayerView:_smallView];
        _smallView.alpha = 0;
        [UIView animateWithDuration:0.1f animations:^{
            _smallView.alpha = 1;
        }];
        // action
        @weakify(self);
        [_smallView setTapAction:^(SmallWinView *smallView) {
            @strongify(self);
//            [self scollPlayViewToOrginCellPosition];
            [self changePlayViewToFullScreen:smallView];
        }];
        [_smallView setCloseAction:^(SmallWinView *smallView) {
            @strongify(self);
            [self.smallView removeFromSuperview];
            [self setSmallView:nil];
            [self.videoCellPlayVM resetUserVideoCellPlayStatus];
        }];
    }
}

// samll view tap action: change to full screen or scoll to orgin position
- (void)changePlayViewToFullScreen:(UIView<AVPlayerViewDelegate>*)fromView {
    // go on play
    FullScreenViewController * fullScreenVC = [[FullScreenViewController alloc]initWithAVPlayerManger:self.videoCellPlayVM.playerManger video:self.videoCellPlayVM.videoVMSource.playingVideo];
    // transition from view
    fullScreenVC.dismissFromViewBlock = ^UIView<AVPlayerViewDelegate> *(){
        return self.smallView;
    };
    // dismiss action
    fullScreenVC.dismissBlock = ^(BOOL isPlayEnd){
        self.videoCellPlayVM.playerManger.delegate = self.videoCellPlayVM;
        MVideo * video = self.videoCellPlayVM.videoVMSource.playingVideo;
        if (isPlayEnd) {
            video.statusLayout.playStatus = VideoPlayStatusEndPlay;
            [self.smallView removeFromSuperview];
            [self setSmallView:nil];
        }
    };
    [self presentViewController:fullScreenVC fromView:fromView animated:YES completion:nil];
}

- (void)scollPlayViewToOrginCellPosition {
    CGRect visibleRect = _playingCellRect;
    CGFloat playViewH  = _playingCellRect.size.height;
    CGFloat centerTopY = (_tableView.height - playViewH)/2;
    CGFloat deltaOrginY = MIN(centerTopY, _minPlayViewTopSpace);
    // 视频cell在屏幕以上，向上滚动回去
    if (_tableView.contentOffset.y > CGRectGetMaxY(visibleRect)) {
        visibleRect.origin.y -= deltaOrginY;
    }
    // 视频cell在屏幕以下，向下滚动回去
    else if (_tableView.contentOffset.y + _tableView.height < CGRectGetMinY(visibleRect)) {
        visibleRect.origin.y += centerTopY;
    }
    
    [self.tableView scrollRectToVisible:visibleRect animated:YES];
}

#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == VideoPlayDidChangeContext) {
        AVPlayerTrack * oldTrack = [change objectForKey:NSKeyValueChangeOldKey];
        AVPlayerTrack * newTrack = [change objectForKey:NSKeyValueChangeNewKey];
        if (oldTrack != newTrack) {
            UserVideoCell * cell = (UserVideoCell *)self.videoCellPlayVM.playingCell;
            self.playingCellRect = [_tableView convertRect:cell.playView.frame fromView:cell.playView.superview];
            
            if (_smallView) {
                [_smallView removeFromSuperview];
                [self setSmallView:nil];
            }
        }
        // KVO
        if (![oldTrack isKindOfClass:NSNull.class]) [oldTrack removeObserver:self forKeyPath:@"isPlayedToEnd"];
        if (![newTrack isKindOfClass:NSNull.class]) [newTrack addObserver:self forKeyPath:@"isPlayedToEnd" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:VideoPlayToEndContext];
    }
    if (context == VideoPlayToEndContext) {
        BOOL isEnd = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isEnd) {
            AVPlayerTrack * track = object;
            if (![track isKindOfClass:NSNull.class]) [track removeObserver:self forKeyPath:@"isPlayedToEnd"];
            if (_smallView && !self.videoCellPlayVM.playerManger.isFullScreenMode) {
                [_smallView removeFromSuperview];
                [self setSmallView:nil];
            }
        }
    }
}

#pragma mark - Push FMVC by tap StatusBar
-(void)pushPlayingAudioVC:(NSNotification*)notification {
    [[OnePlayer onePlayer] playAudioFromController:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.videoCellPlayVM.playerManger.isFullScreenMode) {
        [self.videoCellPlayVM resetUserVideoCellPlayStatus];
    }
}

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
