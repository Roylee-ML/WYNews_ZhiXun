//
//  VideoSortPlayController.m
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "VideoSortPlayController.h"
#import "UserVideoCell.h"
#import "VideoCellPlayVM.h"
#import "ShareManger.h"
#import "NSObject+UIAlert.h"

#define STATUS_HEIGHT  [UIApplication sharedApplication].statusBarFrame.size.height
#define NAV_HEIGHT     self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT  self.tabBarController.tabBar.frame.size.height

static NSString *  VideoSortDataFromDBKey = @"VideoSortDataFromDBKey";

@interface VideoSortPlayController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) VideoCellPlayVM * videoCellPlayVM;
@property (nonatomic, strong) MVideoList * mVideoList;

@end

@implementation VideoSortPlayController

- (instancetype)initWithSortID:(NSString *)sort_id {
    self = [super init];
    if (self) {
        self.sort_id = sort_id;
        VideoSortDataFromDBKey = [VideoSortDataFromDBKey stringByAppendingString:[NSString stringWithFormat:@"_%@",sort_id]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
    [self initNavigationBar];
    [self initData];
    
    __weak typeof(self) weakSelf = self;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
    }
}

- (void)initViews {
    self.tableView = ({
        UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tableView.backgroundColor = [UIColor colorWithHex:@"f2f2f2"];
        tableView.top = NAV_HEIGHT;
        tableView.height = kScreenHeight - NAV_HEIGHT;
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
        tableView;
    });
}

- (void)initNavigationBar {
    //设置导航栏视图
    [[ShareManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@""] andBGImg:[UIImage imageNamed:NC_IMG]];
    // 返回按钮
    UIButton *backButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10,STATUS_HEIGHT + kScreenWidth/80 ,kScreenWidth/15, kScreenWidth/15);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = kScreenWidth/30;
        button.alpha = 0.8;
        [button setBackgroundImage:[[UIImage imageNamed:@"back"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"bobo_top_navigation_back_highlighted"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        [self.view addSubview:button];
        button;
    });
    // action
    [backButton addAction:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData {
    //从数据库读取数据
    NSArray * videoList = [DataBaseHandle getDataArrayWithTitleid:VideoSortDataFromDBKey];
    if (videoList.count != 0) {
        self.mVideoList = [[MVideoList alloc]initWithVideoList:[videoList mutableCopy]];
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
    MVideoList * videoList = [[MVideoList alloc]initWithVideoList:[@[] mutableCopy]];
    [self requestDataWith:videoList];
}

- (void)requestDataWith:(MVideoList *)videoList {
    int currentPage = videoList.currentPage;
    [ShareManger getVideoListWithSortID:_sort_id page:currentPage mVideoList:videoList complicationHandle:^(MVideoList * _videoList) {
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (videoList.videoList.count > 0) {
            self.mVideoList = _videoList;
            //数据库存储
            [DataBaseHandle insertDBWWithArra:_mVideoList.videoList byID:VideoSortDataFromDBKey];
            // vm data update
            self.videoCellPlayVM.videoVMSource.videoSource = self.mVideoList.videoList;
            // refresh UI
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.videoCellPlayVM didSelectRowAtIndexPath:indexPath];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.videoCellPlayVM resetUserVideoCellPlayStatus];
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