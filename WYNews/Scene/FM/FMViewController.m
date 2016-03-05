//
//  FMViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMViewController.h"
#import "FMModel.h"
#import "UIImageView+WebCache.h"
#import "FMListModel.h"
#import "FMPlayingModel.h"
#import "OnePlayer.h"
#import "DataBaseHandle.h"
#import "CollectionListViewController.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

typedef  void(^HandleBlock)();

@interface FMViewController ()

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSDictionary * dataDic;
@property (nonatomic,strong) UIView * headView;
@property (nonatomic,strong) UIImageView * headImgView;
@property (nonatomic,strong) FMSubModel * topModel;
//@property (nonatomic,strong) MBProgressHUD * hud;
//@property (nonatomic,strong) SDRefreshHeaderView * refreshHeader;
@property (nonatomic,strong) NSTimer * outTimer;


@end

@implementation FMViewController

-(instancetype)init
{
    if ([super init]) {
        //        [PersistManger defoutManger].showDelegate = self;
        [PersistManger defoutManger].isPlayingIndex = -1;
    }
    return self;
}

/**********
 -(void)showPlayingAudioAndHidenSmallWindow
 {
 [[OnePlayer onePlayer]playAudioFromController:self];
 }
 ***********/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NC_HEIGHT, SELF_WIDTH, SELF_HEIGHT-(TABBAR_HEIGHT + NC_HEIGHT)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setupHeadView];
    
//    [self performSelector:@selector(showNetworkBad) withObject:nil afterDelay:10.0f];
    
    //下拉刷新
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        [self refreshDataByHandel:nil];
    }];
    
    //加载数据
    [self loadData];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //设置播放电台代理
    [PersistManger defoutManger].playDelegate =self;
    
    //设置导航栏视图
    [[PersistManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@"title1"] andBGImg:[UIImage imageNamed:NC_IMG]];
    //    self.navigationController.navigationBar.alpha = 0;
    self.navigationController.navigationBar.translucent = YES;
    
    [self setupCollectionButton];
}

//设置收藏按钮
-(void)setupCollectionButton
{
    UIButton * collectionBT = [[UIButton alloc]initWithFrame:CGRectMake(LEFT_EDGE, STATUS_HEIGHT + SELF_WIDTH/50, SELF_WIDTH/15, SELF_WIDTH/15)];
    [collectionBT setImage:[[UIImage imageNamed:@"shoucang"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    collectionBT.alpha = 0.8;
    collectionBT.clipsToBounds = YES;
    collectionBT.layer.cornerRadius = collectionBT.frame.size.width/2;
    [collectionBT addTarget:self action:@selector(didClickShowCollectionList:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:collectionBT];
}

-(void)didClickShowCollectionList:(UIButton*)button
{
    CollectionListViewController * collectionVC = [[CollectionListViewController alloc]init];
    
    collectionVC.hidesBottomBarWhenPushed = YES;
    
    if ([PersistManger defoutManger].isPlayingIndex >= 0) {
        collectionVC.isPlayingIndex = [PersistManger defoutManger].isPlayingIndex;
    }
    
    [self.navigationController pushViewController:collectionVC animated:YES];
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

//加载数据
-(void)loadData
{
    
    //数据库
    NSDictionary * dic = [DataBaseHandle getDataDictionaryWithTitleid:NSStringFromClass([self class])];
    if (dic) {
        self.dataDic = dic;
        
        //设置头图图片
        self.topModel = (FMSubModel*)dic[kFMListTop];
        [_headImgView sd_setImageWithURL:[NSURL URLWithString:_topModel.imgsrc] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
//        [[self class]cancelPreviousPerformRequestsWithTarget:self];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
        
    }else{
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
}

//刷新数据
-(void)refreshDataByHandel:(HandleBlock)handle
{
    //加载数据
    __weak FMViewController * sself = self;
    [PersistManger getFMDataWithUrl:[NSURL URLWithString:FM_URL] andByHandle:^(NSDictionary *dic) {
        
        if (dic.count != 0) {
            //设置头图图片
            self.topModel = (FMSubModel*)dic[kFMListTop];
            [_headImgView sd_setImageWithURL:[NSURL URLWithString:_topModel.imgsrc] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
            
            //加载数据
            sself.dataDic = nil;
            sself.dataDic = dic;
            [DataBaseHandle insertDBWWithDictionary:sself.dataDic byID:NSStringFromClass([self class])];
            
            if (handle) {
                handle();
            }
            
            [self.tableView.header endRefreshing];
            if (_outTimer) {
                [_outTimer invalidate];
                _outTimer = nil;
            }
            [sself.tableView reloadData];
        }
    }];
}


//创建头视图
-(void)setupHeadView
{
    self.headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, SELF_WIDTH * 3/7)];
    _headView.backgroundColor = [UIColor whiteColor];
    _headView.clipsToBounds = YES;
    _headView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton * playHeadBT = [[UIButton alloc]initWithFrame:_headView.frame];
    [playHeadBT addTarget:self action:@selector(playHeadAudio) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:playHeadBT];
    
    self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH,SELF_WIDTH*3/7)];
    _headImgView.contentMode = UIViewContentModeScaleToFill;
    _headImgView.clipsToBounds = YES;
    
    [self.headView addSubview:_headImgView];
    
    self.tableView.tableHeaderView = _headView;
    
}

//头视图播放操作
-(void)playHeadAudio
{
    NSLog(@"开始播放");
    
    //先暂停player
    [[OnePlayer onePlayer] pause];
    
    //提示网络
    [[PersistManger defoutManger] judgeNetStatusAndAlert];
    
    FMPlayListViewController * playListVC = [[FMPlayListViewController alloc]init];
    playListVC.cateName = _topModel.tname;
    playListVC.coverImg = _headImgView.image;
    playListVC.dbDocidKey = _topModel.docid;
    [playListVC.animateView resetAnimateAndPause];
    
    //设置数据库，每次点击不同唱片，之前的数据库清空。
    NSString * ddocid = [PersistManger getMark];
    if (![_topModel.docid isEqualToString:ddocid]) {
        [DataBaseHandle deleteDataByTitleID:ddocid];
        
        [PersistManger setMark:_topModel.docid];
        
        [PersistManger setRefreshPage:1];
    }
    
    NSArray * dataArr = [DataBaseHandle getDataArrayWithTitleid:_topModel.docid];
    if (dataArr) {
        playListVC.listModelArray = [dataArr mutableCopy];
        FMPlayingModel * playingModel = (FMPlayingModel*)([DataBaseHandle getDataArrayWithTitleid:_topModel.tname].lastObject);
        playListVC.playingModel = playingModel;
        
        [[OnePlayer onePlayer] playAudioWithTid:playingModel.tid andUrl:playingModel.url_mp4 toController:playListVC];
        
        //        [[PersistManger defoutManger]hideProgressHUD];
    
    }else{
        //获取数据
        [PersistManger getFMPlayingDataWithUrl:_topModel.docid andByHandle:^(id model) {
            FMPlayingModel * playModel = model;
            
            playListVC.playingModel = playModel;
            
            [DataBaseHandle insertDBWWithArra:@[playModel] byID:_topModel.tname];
            
            //获取列表数据
            [PersistManger getFMPlayListDataWithUrl:playModel.tid page:1 andByHandle:^(NSArray *arr) {
                playListVC.listModelArray = [arr mutableCopy];
                
                [DataBaseHandle insertDBWWithArra:arr byID:_topModel.docid];
                
                [playListVC.listTableView reloadData];
                
                [[OnePlayer onePlayer] playAudioWithTid:playModel.tid andUrl:playModel.url_mp4 toController:playListVC];
                
            }];
        }];
    }
    
    [playListVC setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:playListVC animated:YES];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataDic) {
        return [_dataDic[kFMModelList] count];
    }else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.frame.size.width*2/3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fmCell"];
    if (!cell) {
        cell = [[FMTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fmCell"];
    }
    
    if (_dataDic) {
        NSArray * dataArray = _dataDic[kFMModelList];
        cell.fm_model = dataArray[indexPath.row];
        
        [cell setupImageForTitleAtindex:indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
#pragma mark ------ 定义cell导航栏点击block事件 -----
    __weak FMViewController * sself =self;
    cell.enterBlock = ^(NSString * cid){
        FMPlateViewController * fmPlateVC = [[FMPlateViewController alloc]init];
        
        NSArray * arr = _dataDic[kFMModelList];
        FMModel * model = arr[indexPath.row];
//        fmPlateVC.navigationItem.title = model.cname;
        fmPlateVC.model = model;
        
        [fmPlateVC setHidesBottomBarWhenPushed:YES];
        
        [sself.navigationController pushViewController:fmPlateVC animated:YES];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了..........");
}

#pragma mark ----- 实现点击播放的协议 ----
-(void)playFMAudioWithaDocid:(NSString*)docid tname:(NSString *)tname andImage:(UIImage *)img
{
    //先暂停player
    [[OnePlayer onePlayer] pause];
    
    FMPlayListViewController * playListVC = [[FMPlayListViewController alloc]init];
    playListVC.cateName = tname;
    playListVC.coverImg = img;
    playListVC.dbDocidKey = docid;
    [playListVC.animateView resetAnimateAndPause];
    
    //设置数据库，每次点击不同唱片，之前的数据库清空。
    NSString * ddocid = [PersistManger getMark];
    if (![docid isEqualToString:ddocid]) {
        [DataBaseHandle deleteDataByTitleID:ddocid];
        
        [PersistManger setMark:docid];
        
        [PersistManger setRefreshPage:1];
    }
    
//[[PersistManger defoutManger]showProgressHUDToView:playListVC.view overTimeByHandle:^{
    
//}];
    NSLog(@"点击了button......");
    
    //提示网络
    [[PersistManger defoutManger] judgeNetStatusAndAlert];
    
    NSArray * dataArr = [DataBaseHandle getDataArrayWithTitleid:docid];
    if (dataArr) {
        playListVC.listModelArray = [dataArr mutableCopy];
        FMPlayingModel * playingModel = (FMPlayingModel*)([DataBaseHandle getDataArrayWithTitleid:tname].lastObject);
        playListVC.playingModel = playingModel;
        
        [[OnePlayer onePlayer] playAudioWithTid:playingModel.tid andUrl:playingModel.url_mp4 toController:playListVC];
        
//        [[PersistManger defoutManger]hideProgressHUD];
        
    }else{
        //获取数据
        [PersistManger getFMPlayingDataWithUrl:docid andByHandle:^(id model) {
            FMPlayingModel * playingModle = (FMPlayingModel*)model;
            
            //获取列表数据
            [PersistManger getFMPlayListDataWithUrl:playingModle.tid page:1 andByHandle:^(NSArray *arr) {
                playListVC.listModelArray = [arr mutableCopy];
                
                if (arr.count != 0) { //避免后台数据更新时palyingModel没有更新。
                    FMListModel * model = arr[0];
                    
                    //获取第一个音频
                    [PersistManger getFMPlayingDataWithUrl:model.docid andByHandle:^(id model) {
                        if (model) {
                            FMPlayingModel * fmPlayingModle = model;
                            [DataBaseHandle insertDBWWithArra:@[fmPlayingModle] byID:tname];
                            
                            playListVC.playingModel = fmPlayingModle;
                            
                            [playListVC setupPlayImageAndTileWith:fmPlayingModle];
                            
                            [[OnePlayer onePlayer] playAudioWithTid:fmPlayingModle.tid andUrl:fmPlayingModle.url_mp4 toController:playListVC];
                            
                            NSLog(@"mp4____________________%@",fmPlayingModle.url_mp4);
                        }
                    }];
                }else{
                    playListVC.playingModel = playingModle;
                    
                    [DataBaseHandle insertDBWWithArra:@[playingModle] byID:tname];
                    
                    [playListVC setupPlayImageAndTileWith:playingModle];
                    
                    [[OnePlayer onePlayer] playAudioWithTid:playingModle.tid andUrl:playingModle.url_mp4 toController:playListVC];
                    
                    NSLog(@"mp4____________________%@",playingModle.url_mp4);
                }
                    
                [DataBaseHandle insertDBWWithArra:playListVC.listModelArray byID:docid];
                
                [playListVC.listTableView reloadData];
                
                 /*
                     [DataBaseHandle insertDBWWithArra:@[playingModle] byID:tname];
                     
                     playListVC.playingModel = playingModle;
                     
                     [playListVC setupPlayImageAndTileWith:playingModle];
                     
                     [playListVC.listTableView reloadData];
                     
                     [[OnePlayer onePlayer] playAudioWithTid:playingModle.tid andUrl:playingModle.url_mp4 toController:playListVC];
                     
                     NSLog(@"mp4____________________%@",playingModle.url_mp4);
                     
                 */
                    
                    //                [[PersistManger defoutManger]hideProgressHUD];
            }];
        }];
    }
    
    [playListVC setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:playListVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPlayingAudioVC:) name:BackAudioMark object:nil];
}

-(void)pushPlayingAudioVC:(NSNotification*)notification
{
    [[OnePlayer onePlayer]playAudioFromController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //iOS 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;    //让rootView禁止滑动
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}

#pragma mark ----隐藏导航栏----
//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}

////手势代理方法
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//
//    if ([touch.view isKindOfClass:[UIButton class]]){
//
//        NSLog(@"执行了方法----");
//        return NO;
//    }
//    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
//
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//
//        NSLog(@"执行了方法++--");
//        return NO;
//    }
//
//    NSLog(@"执行了方法+++++");
//    return NO;
//}

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
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
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
