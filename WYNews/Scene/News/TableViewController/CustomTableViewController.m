//
//  CustomTableViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CustomTableViewController.h"
#import "CostomCell.h"
#import "ImageCell.h"
#import "DataModel.h"
#import "UIImageView+WebCache.h"
#import "NSString+StringHeight.h"

#import "SDRefresh.h"
#import "CommonDetailViewController.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.parentViewController.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface CustomTableViewController ()

@property (nonatomic, strong) NSTimer *outTimer;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, assign) int Count;

@property (nonatomic,strong) NSMutableArray * fontArr;
@property (nonatomic,strong) NSTimer * myTimer;
@property (nonatomic,strong) MBProgressHUD * hud;
@property (nonatomic,strong) HeadView * headView;


@end

@implementation CustomTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉刷新
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        [self refreshView];
    }];

    NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
    if (dataArray) {
        self.array = [dataArray mutableCopy];
        
        //给tableview添加头图
        self.headView.delegate=self;
        [self.headView refreshViewUI];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
        
    }else{
        //开辟空间
        self.array =[[NSMutableArray alloc]init];
        //刷新
        self.headView.delegate = self;
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    
   //页面计数为1
   self.Count=1;
     //上拉加载
   [self setupFooter];
    
    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"CostomCell" bundle:nil] forCellReuseIdentifier:@"mycell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
}

////清除缓存
//-(void)clearDisk
//{
//    [PersistManger clearAlertShowByVC:self];
//}

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

//上拉加载
- (void)setupFooter 
{
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooterView)];
}

-(void)refreshFooterView{
    
    NSString * pageCount=[NSString stringWithFormat:@"%d-%d", 20+(_Count-1)*20,20];
    NSString *url=[NSString stringWithFormat:@"http://c.m.163.com/nc/article/headline/T1348647853363/%@.html",pageCount ];
    
    NSRange range=NSMakeRange(39, 14);
    NSString * str=[url substringWithRange:range];
    
    __weak CustomTableViewController * sself = self;
    
    [PersistManger jsonDataUrl:url Stringkey:str andByHandle:^(NSArray * dataArray) {
        NSMutableArray * array=[[NSMutableArray alloc]initWithArray:dataArray];
        //新加载的数据添加到原来的数组中
        [sself.array addObjectsFromArray:array];
        
        [sself.tableView reloadData];
        _Count ++;
        
        [self.tableView.footer setState:MJRefreshStateIdle];
    }];
}


//下拉刷新
-(void)refreshView{
    
//    NSString * pageCount=[NSString stringWithFormat:@"%ld-%d",_Count>1? 60+(_Count-2)*20:0,_Count>1?20:60];
//    NSString *url=[NSString stringWithFormat:@"http://c.m.163.com/nc/article/headline/T1348647853363/%@.html",pageCount ];
//    NSLog(@"%@",url);
    //网址
    NSString * url=@"http://c.m.163.com/nc/article/headline/T1348647853363/0-20.html";
    //截取字符串作为字典的key
    NSRange range=NSMakeRange(39, 14);
    NSString * str=[url substringWithRange:range];
    
    //解析数据
    
    __weak CustomTableViewController * sself = self;
    [PersistManger jsonDataUrl:url Stringkey:str andByHandle:^(NSArray * dataArray) {
        if (dataArray.count != 0) {
            NSMutableArray * array=[[NSMutableArray alloc]initWithArray:dataArray];
            
            DataModel * dataModel=array[0];
            //单例传值到轮播图
            //        [PersistManger defoutManger].dataModel=dataModel;
            //移除第一个model
            [array removeObjectAtIndex:0];
            if (sself.array.count != 0) {
                [sself.array removeAllObjects];
                [sself.array addObjectsFromArray:array];
            }else{
                sself.array = array;
            }
            
            [DataBaseHandle insertDBWWithArra:_array byID:NSStringFromClass([self class])];
            [DataBaseHandle insertDBWWithArra:@[dataModel] byID:HeadViewKey];
            
            NSLog(@"dataModel ==== %@",dataModel);
            
            [self.headView refreshHeadViw];
            
            [self.tableView reloadData];
            
            [self.tableView.header endRefreshing];
            if (_outTimer) {
                [_outTimer invalidate];
                _outTimer = nil;
            }
        }
    }];
}

-(HeadView*)headView
{
    if (!_headView) {
        _headView = [[HeadView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.53*WIDTH)];
        self.tableView.tableHeaderView = _headView;
    }
    return _headView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if (_array.count>0) {
        return self.array.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_array.count>0) {
        DataModel * model=self.array[indexPath.row];
        
        if (model.imgextra==nil) {
            CostomCell * cell=[tableView dequeueReusableCellWithIdentifier:@"mycell"];
            //        if (!cell) {
            //
            //            [tableView registerNib:[UINib nibWithNibName:@"CostomCell" bundle:nil] forCellReuseIdentifier:@"mycell"];
            //            cell=[[CostomCell alloc]initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"mycell"];
            //        }
            cell.model=model;
            NSURL * url=[[NSURL alloc]initWithString:model.imgsrc];
            [cell.imgView sd_setImageWithURL:url];
            cell.titleLable.text=model.title;
            [cell.digestLable setAttributedText:[NSString stringHigehtBy:LINE_HEIGHT withString:model.digest]];
            cell.titleLable.font = [UIFont systemFontOfSize:TitleFont_Size -2];
            cell.digestLable.font = [UIFont systemFontOfSize:TitleFont_Size-4];
            
            return cell;
        }else{
            
            ImageCell * cell=[tableView dequeueReusableCellWithIdentifier:@"myCell"];
            //        if (!cell) {
            ////            cell=[[ImageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"myCell"];
            //       }
            
            cell.model=model;
            cell.titleLable.text=model.title;
            cell.titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
            NSURL * url=[[NSURL alloc]initWithString:model.imgsrc];
            NSURL * url1=[[NSURL alloc]initWithString:model.imgsrc1];
            NSURL * url2=[[NSURL alloc]initWithString:model.imgsrc2];
            //第三方下载数据
            [cell.imgView sd_setImageWithURL:url];
            [cell.imgView1 sd_setImageWithURL:url1];
            [cell.imgView2 sd_setImageWithURL:url2];
            
            return cell;
        }
    }else{
        CostomCell * cell=[tableView dequeueReusableCellWithIdentifier:@"mycell"];
//        cell.textLabel.text = [NSString stringWithFormat:@"字体%@",_fontArr[indexPath.row]];
//        cell.textLabel.font = [UIFont fontWithName:_fontArr[indexPath.row] size:17];
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.293*WIDTH;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataModel * model=self.array[indexPath.row];
    
    if (!model.photosetID) {
        CommonDetailViewController * commenVC=[[CommonDetailViewController alloc]init];
        commenVC.hidesBottomBarWhenPushed = YES;
        commenVC.docid=model.docid;
        
        [self.navigationController pushViewController:commenVC animated:YES];
    }else{
        PhotosetDetailController * photoVC=[[PhotosetDetailController alloc]init];
        
        photoVC.setid=model.photosetID ;
        
        NSLog(@"id ============= %@",photoVC.setid);
        
        photoVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:photoVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"取消点击行了......");
//}

//执行协议方法
-(void)pushphotoDetailViewControllerWithID:(NSString *)setid{
    
    if ([setid length]>10) {
        CommonDetailViewController * commonVC = [[CommonDetailViewController alloc]init];
        commonVC.docid = setid;
        commonVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:commonVC animated:YES];
    }else{
        PhotosetDetailController * photoVC=[[PhotosetDetailController alloc]init];
        
        photoVC.setid=setid;
        NSLog(@"-------%@",setid);
        photoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:photoVC animated:YES];
    }
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

@end
