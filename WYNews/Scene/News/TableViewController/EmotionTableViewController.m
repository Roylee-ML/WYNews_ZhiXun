//
//  EmotionTableViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "EmotionTableViewController.h"
#import "NSString+StringHeight.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.parentViewController.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface EmotionTableViewController ()

@property (nonatomic, strong) NSTimer *outTimer;
@property (nonatomic, assign) int Count;
@property (nonatomic,strong) UIImageView * imgView;
@property (nonatomic,strong) UILabel * titleLable;


@end

@implementation EmotionTableViewController

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
        [self loadData];
    }];
    
    self.oneArray=[[NSMutableArray alloc]init];

    NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
    if (dataArray) {
        NSMutableArray * array = [dataArray mutableCopy];
        
        DataModel * model=array[0];
        [self.oneArray addObject:model];
        
        //第三方下载图片
        [_imgView sd_setImageWithURL:[NSURL URLWithString:model.imgsrc]];
        _titleLable.text=model.title;
        
        [array removeObjectAtIndex:0];
        self.array=array;
                
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
        
    }else{
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    

    self.Count=1;
    //上拉加载
    [self setupFooter];

    //注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"CostomCell" bundle:nil] forCellReuseIdentifier:@"mycell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellReuseIdentifier:@"myCell"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

-(void)loadData{
    
    NSString * url=@"http://c.m.163.com/nc/article/list/T1348650839000/0-20.html";

    NSRange range=NSMakeRange(35, 14);
    NSString * str=[url substringWithRange:range];
    
    __weak EmotionTableViewController * sself =self;
    [ShareManger jsonDataUrl:url Stringkey:str andByHandle:^(NSArray *dataArray) {
        if (dataArray.count != 0) {
            NSMutableArray * array=[[NSMutableArray alloc]initWithArray:dataArray];
            DataModel * model=array[0];
            if (self.oneArray.count != 0) {
                [_oneArray removeAllObjects];
            }
            [self.oneArray addObject:model];
            
            //第三方下载图片
            [_imgView sd_setImageWithURL:[NSURL URLWithString:model.imgsrc]];
            _titleLable.text=model.title;
            
            [array removeObjectAtIndex:0];
            if (sself.array.count != 0) {
                [sself.array removeAllObjects];
                [sself.array addObjectsFromArray:array];
            }else{
                sself.array = array;
            }
            
            [DataBaseHandle insertDBWWithArra:dataArray byID:NSStringFromClass([self class])];
            [[ShareManger defoutManger]hideProgressHUD];
            
            [self.tableView.header endRefreshing];
            if (_outTimer) {
                [_outTimer invalidate];
                _outTimer = nil;
            }
            
            [sself.tableView reloadData];
        }
    }];
}

//创建头图
-(void)setupHeadView
{
    //创建相册存放图片
    self.imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH , 0.48*WIDTH-6)];
    _imgView.clipsToBounds = YES;
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    //创建标题lable
    self.titleLable=[[UILabel alloc]initWithFrame:CGRectMake(5, 0.48*WIDTH -3, WIDTH-5, 0.053*WIDTH)];
    
    _titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    //创建heedView 作为tabeView的头视图
    UIView * headView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.53*WIDTH)];
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame= CGRectMake(0, 0, WIDTH, 0.53*WIDTH);
    button.backgroundColor=[UIColor clearColor];
    [button addTarget:self action:@selector(pushDetailView:) forControlEvents: UIControlEventTouchUpInside ];
    [headView addSubview:_imgView];
    [headView addSubview:button];
    [headView addSubview:_titleLable];
    self.tableView.tableHeaderView=headView;
}


////上拉加载
- (void)setupFooter
{
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self refreshFooterView];
    }];
}

-(void)refreshFooterView{
    
    
    NSString * pageCount=[NSString stringWithFormat:@"%d-%d", 20+(_Count-1)*20,20];
    NSString *url=[NSString stringWithFormat:@"http://c.m.163.com/nc/article/list/T1348650839000/%@.html",pageCount ];
    
    //截取网址中的字符作为字典的key 获取数据
    NSRange range=NSMakeRange(35, 14);
    NSString * str=[url substringWithRange:range];
    //解析数据
    
    __weak EmotionTableViewController * sself =self;
    [ShareManger jsonDataUrl:url Stringkey:str andByHandle:^(NSArray *dataArray) {
        NSMutableArray * array=[[NSMutableArray alloc]initWithArray:dataArray];
        
        [sself.array addObjectsFromArray:array];
        
        [sself.tableView reloadData];
        
        _Count ++;
        
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_array.count != 0) {
        DataModel * model=self.array[indexPath.row];
        if (model.imgextra==nil) {
            CostomCell * cell=[tableView dequeueReusableCellWithIdentifier:@"mycell"];
            //        if (!cell) {
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
            //            cell=[[ImageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"myCell5"];
            //        }
            
            cell.model=model;
            NSURL * url=[[NSURL alloc]initWithString:model.imgsrc];
            NSURL * url1=[[NSURL alloc]initWithString:model.imgsrc1];
            NSURL * url2=[[NSURL alloc]initWithString:model.imgsrc2];
            [cell.imgView sd_setImageWithURL:url];
            [cell.imgView1 sd_setImageWithURL:url1];
            [cell.imgView2 sd_setImageWithURL:url2];
            cell.titleLable.text=model.title;
            cell.titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
            tableView.backgroundColor = [UIColor whiteColor];
            return cell;
        }

    }else{
        CostomCell * cell=[tableView dequeueReusableCellWithIdentifier:@"mycell"];
        
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 0.293*WIDTH;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataModel * model=self.array[indexPath.row];
    CommonDetailViewController * commenVC=[[CommonDetailViewController alloc]init];
    
    PhotosetDetailController * photoVC=[[PhotosetDetailController alloc]init];
    if (!model.photosetID) {
        commenVC.hidesBottomBarWhenPushed = YES;
        commenVC.docid=model.docid;
        [self.navigationController pushViewController:commenVC animated:YES];
        
        
    }else{
        photoVC.hidesBottomBarWhenPushed = YES;
        photoVC.setid=model.photosetID ;
        [self.navigationController pushViewController:photoVC animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//点击headView推出页面
-(void)pushDetailView:(UIButton * )BI{
    
    
    DataModel * model=self.oneArray[0];
    if (model.photosetID==nil) {
        CommonDetailViewController * commenVC=[[CommonDetailViewController alloc]init];
        commenVC.docid=model.docid;
        
        commenVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:commenVC animated:YES];
    }else{
        PhotosetDetailController * photoVC=[[PhotosetDetailController alloc]init];
        photoVC.setid=model.photosetID;
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
