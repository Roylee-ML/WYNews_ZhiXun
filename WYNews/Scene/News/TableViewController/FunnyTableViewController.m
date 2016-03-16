//
//  FunnyTableViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FunnyTableViewController.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width 
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.parentViewController.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface FunnyTableViewController ()

@property (nonatomic, strong) NSTimer *outTimer;

@end

@implementation FunnyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeadView];
    
    //下拉刷新
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        [self reloadView];
    }];
    
    NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
    if (dataArray.count != 0) {
        self.array = [dataArray mutableCopy];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }else{
        self.array=[[NSMutableArray alloc]init];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    
    [self setupFooter];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)reloadView{
    NSString * funUrl=@"http://c.3g.163.com/recommend/getChanRecomNews?channel=duanzi&passport=&devId=54555A0E-9F1B-4481-AEF4-F84D43BD8764&size=20";
    NSURL * url=[[NSURL alloc]initWithString:funUrl];
    
    NSURLRequest * request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!data) {
            return ;
        }
        
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        
        NSArray * dataArray=dic[@"段子"];
        
        if (self.array.count != 0) {
            [_array removeAllObjects];
        }
        
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary * dict=dataArray[i];
            FunModel * model=[[FunModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [self.array addObject:model];
            
        }
        
        [DataBaseHandle insertDBWWithArra:_array byID:NSStringFromClass([self class])];
        
        [self.tableView.header endRefreshing];
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        [self.tableView reloadData];
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


////上拉加载
- (void)setupFooter
{
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self refreshFooterView];
    }];
}

-(void)refreshFooterView{
    
     NSString * funUrl=@"http://c.3g.163.com/recommend/getChanListNews?channel=duanzi&passport=&devId=BBE4CE0B-85EC-40A8-B8BD-BA41A0CCF8BA&size=20";
  
    NSURL * url=[[NSURL alloc]initWithString:funUrl];
    NSMutableArray * array=[[NSMutableArray alloc]init];
    NSURLRequest * request=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        NSArray * dataArray=dic[@"段子"];
        
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary * dict=dataArray[i];
            FunModel * model=[[FunModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [array addObject:model];
            
        }
        [self.array addObjectsFromArray:array];
        [self.tableView reloadData];
        
        [self.tableView.footer setState:MJRefreshStateIdle];
    }];
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
    if (_array.count != 0) {
        return self.array.count;
    }else{
        return 0;
    }
}

-(void)setupHeadView
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    self.tableView.tableHeaderView = view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_array.count != 0) {
        FunModel * model=self.array[indexPath.row];
        if (model.imgsrc==nil) {
            FunnyCell * cell=[tableView dequeueReusableCellWithIdentifier:@"funCell"];
            if (!cell) {
                cell=[[FunnyCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"funCell"];
            }
            
            cell.model=model;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        }else{
            FunnyImageCell * cell=[tableView dequeueReusableCellWithIdentifier:@"funcell"];
            if (!cell) {
                cell=[[FunnyImageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"funcell"];
            }
            cell.model=model;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }

    }else{
        FunnyCell * cell=[tableView dequeueReusableCellWithIdentifier:@"funCell"];
        if (!cell) {
            cell=[[FunnyCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"funCell"];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}





-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_array.count != 0) {
        FunModel * model=self.array[indexPath.row];
        if (model.imgsrc==nil) {
            CGFloat height= [FunnyCell textLableHeight:model.digest];
            return height+0.10667*WIDTH;
        }else{
            CGFloat height= [FunnyCell textLableHeight:model.digest];
            NSString * str=model.pixel;
            NSRange range=NSMakeRange(0, 3);
            NSRange range1=NSMakeRange(4, 3);
            NSString * widthString=[str substringWithRange:range];
            CGFloat imgWidth=[widthString floatValue];
            NSString * heightString=[str substringWithRange:range1];
            CGFloat imgHeight =[heightString floatValue];
            
            CGFloat  heightX=0.94667*WIDTH*imgHeight/imgWidth;
            
            return heightX+height+0.0533*WIDTH;
        }
    }else{
        return 100;
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
