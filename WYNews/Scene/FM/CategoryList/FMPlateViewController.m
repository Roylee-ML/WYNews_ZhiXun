//
//  FMPlateViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMPlateViewController.h"
#import "OnePlayer.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height

@interface FMPlateViewController ()

@property (nonatomic,strong) UIButton * backBT;
@property (nonatomic,strong) NSTimer * outTimer;

@end

@implementation FMPlateViewController

-(instancetype)init
{
    if ([super init]) {
//        [ShareManger defoutManger].showDelegate = self;
    }
    return self;
}

/*************
-(void)showPlayingAudioAndHidenSmallWindow
{
    [[OnePlayer onePlayer]playAudioFromController:self];
}
*************/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NC_HEIGHT, SELF_WIDTH, SELF_HEIGHT-NC_HEIGHT)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    // 配置返回按钮
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //title必须设置空，因为item由两部分组成。
    backItem.title = @"";
    
    self.navigationItem.leftBarButtonItem = backItem;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    //设置导航栏视图
    [[ShareManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@"title1"] andBGImg:[UIImage imageNamed:NC_IMG]];
    
    //创建返回按钮
    self.backBT = [[UIButton alloc]initWithFrame:CGRectMake(10, STATUS_HEIGHT+SELF_WIDTH/80, SELF_WIDTH*1.0/15, SELF_WIDTH*1.0/15)];
    [_backBT setImage:[[UIImage imageNamed:BACK_ICON] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    _backBT.alpha = 0.8;
    
    [_backBT addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_backBT];
    
    //下拉刷新
    self.tableView.header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        
        //请求数据
        [ShareManger getFMCateListDataWithUrl:_model.cid page:1 andByHandel:^(NSArray *arr) {
            if (!self.dataArray) {
                self.dataArray = [@[] mutableCopy];
            }
            
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:arr];
            [self.tableView reloadData];
            
            [DataBaseHandle insertDBWWithArra:self.dataArray byID:_model.cid];
            
            [self.tableView.header endRefreshing];
            
            if (_outTimer) {
                [_outTimer invalidate];
                _outTimer = nil;
            }
        }];
    }];
    
    NSArray * dataArr = [DataBaseHandle getDataArrayWithTitleid:_model.cid];
    if (dataArr) {
        self.dataArray = [dataArr mutableCopy];
        
        [self.tableView.header beginRefreshing];
        
    }else{
        [self.tableView.header beginRefreshing];
    }

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

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataArray.count != 0) {
        return _dataArray.count;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SELF_WIDTH * 1/4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMCateListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cateCell"];
    if (!cell) {
        cell = [[FMCateListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cateCell"];
    }
    
    if (_dataArray.count != 0) {
        
        cell.model = _dataArray[indexPath.row];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //先暂停player
    [[OnePlayer onePlayer] pause];
    
    //提示网络
    [[ShareManger defoutManger] judgeNetStatusAndAlert];
    
    FMCateListTableViewCell * cell = (FMCateListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    FMPlayListViewController * playListVC = [[FMPlayListViewController alloc]init];
    
//    [MBProgressHUD showHUDAddedTo:playListVC.view animated:YES];
    //获取数据
    FMSubModel * model = _dataArray[indexPath.row];
    
    playListVC.cateName = model.tname;
    playListVC.coverImg = cell.headImgView.image;
    playListVC.dbDocidKey = model.docid;
    [playListVC.animateView resetAnimateAndPause];
    
    [ShareManger getFMPlayingDataWithUrl:model.docid andByHandle:^(id model) {
        FMPlayingModel * playModel = model;
        
        playListVC.playingModel = playModel;
        
        //获取列表数据
        [ShareManger getFMPlayListDataWithUrl:playModel.tid page:1 andByHandle:^(NSArray *arr) {
            playListVC.listModelArray = [arr mutableCopy];
            
            [playListVC.listTableView reloadData];
            
            [[OnePlayer onePlayer]playAudioWithTid:playModel.tid andUrl:playModel.url_mp4 toController:playListVC];
            
//            [MBProgressHUD hideHUDForView:playListVC.view animated:YES];
        }];
    }];
    
    playListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:playListVC animated:YES];
    
    //取消点击状态
    [self performSelector:@selector(deselectRowAtIndex:) withObject:indexPath afterDelay:0.1];
    
}

-(void)deselectRowAtIndex:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
    [[ShareManger defoutManger]removeHUD];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
    [[ShareManger defoutManger]removeHUD];
}

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

@end
