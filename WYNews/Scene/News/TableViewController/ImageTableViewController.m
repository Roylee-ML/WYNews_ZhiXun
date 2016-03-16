//
//  ImageTableViewController.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ImageTableViewController.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.parentViewController.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface ImageTableViewController ()

@property (nonatomic, strong) NSTimer *outTimer;
@property (nonatomic, assign) NSInteger Count;

@end

@implementation ImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉刷新
    self.tableView.header=[MJRefreshStateHeader headerWithRefreshingBlock:^{
        if (_outTimer) {
            [_outTimer invalidate];
            _outTimer = nil;
        }
        self.outTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(showNetWorkBad) userInfo:nil repeats:NO];
        [self loadData];
    }];

    NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
    if (dataArray) {
        self.array = [dataArray mutableCopy];
        
        
        [self setupHeadView];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }else{
        self.array=[[NSMutableArray alloc]init];
        
        [self setupHeadView];
        
        //进入页面自动强制加载一次数据
        [self.tableView.header beginRefreshing];
    }
    
    //页面计数为1
    self.Count=1;
    //上拉加载
    [self setupFooter];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImgCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImgeCell1" bundle:nil] forCellReuseIdentifier:@"cell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImgCell2" bundle:nil] forCellReuseIdentifier:@"cell2"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//下拉刷新
-(void)loadData{
    NSString * imgurl=@"http://c.m.163.com/photo/api/list/0096/54GI0096.json";
    _Count=1;
    //创建网址对象
    NSURL * url=[[NSURL alloc]initWithString:imgurl];
    //创建请求对象
    NSURLRequest * request=[[NSURLRequest alloc]initWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:60.0];
    //创建连接方式
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!data) {
            return ;
        }
        NSArray  * dataArray=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        if (self.array.count != 0) {
            [_array removeAllObjects];
        }
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary * dic=dataArray[i];
            NSArray * picArray =dic[@"pics"];
            if (picArray.count>0) {
                NSString * imgUrl=picArray[0];
                NSString * imgUrl1=picArray[1];
                NSString * imgUrl2=picArray[2];
                [dic setValue:imgUrl forKey:@"img1"];
                [dic setValue:imgUrl1 forKey:@"img2"];
                [dic setValue:imgUrl2 forKey:@"img3"];
                ImgModel * imgModel=[[ImgModel alloc]init];
                [imgModel setValuesForKeysWithDictionary:dic];
                [self.array addObject:imgModel];
                
            }
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

//上拉加载
- (void)setupFooter
{
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self refreshFooterView];
    }];
}

-(void)refreshFooterView{
    ImgModel * model=self.array.lastObject;
    
    
   // NSString * imgurl=  @"http://c.m.163.com/photo/api/morelist/0096/54GI0096/67319.json";
    NSString * imgurl=[NSString stringWithFormat:@"http://c.m.163.com/photo/api/morelist/0096/54GI0096/%@.json",model.setid];
    
    
    //创建网址对象
    NSURL * url=[[NSURL alloc]initWithString:imgurl];
    //创建请求对象
    NSURLRequest * request=[[NSURLRequest alloc]initWithURL:url cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:60.0];
    NSMutableArray * tempModelArray=[[NSMutableArray alloc]init];
    //创建连接方式
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSArray  * dataArray=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
        
        if (!data) {
            return ;
        }
        for (int i=0; i<dataArray.count; i++) {
            NSDictionary * dic=dataArray[i];
            NSArray * picArray =dic[@"pics"];
            if (picArray.count>0) {
                NSString * imgUrl=picArray[0];
                NSString * imgUrl1=picArray[1];
                NSString * imgUrl2=picArray[2];
                [dic setValue:imgUrl forKey:@"img1"];
                [dic setValue:imgUrl1 forKey:@"img2"];
                [dic setValue:imgUrl2 forKey:@"img3"];
                ImgModel * imgModel=[[ImgModel alloc]init];
                [imgModel setValuesForKeysWithDictionary:dic];
                [tempModelArray addObject:imgModel];
            }
            
        }
        [self.array addObjectsFromArray:tempModelArray];
        
        [self.tableView reloadData];
        
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

    NSLog(@"==========array %@ count %ld",_array,(unsigned long)_array.count);
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
        ImgModel * model=self.array[indexPath.row];
        
        int index= indexPath.row%3;
        if (index==0) {
            ImgCell * cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
//            if (!cell) {
//                cell=[[ImgCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
//            }
            [cell.imgeView sd_setImageWithURL:[NSURL URLWithString:model.img1]];
            cell.titleLable.text=model.setname;
            cell.titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];

            return cell;
        }else if(index==1){
            ImgeCell1 * cell=[tableView dequeueReusableCellWithIdentifier:@"cell1"];
            //        if (!cell) {
            //            cell=[[ImgCell1 alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell1"];
            //        }
            [cell.imgView1 sd_setImageWithURL:[NSURL URLWithString:model.img1]];
            [cell.imgView2 sd_setImageWithURL:[NSURL URLWithString:model.img2]];
            [cell.imgView3 sd_setImageWithURL:[NSURL URLWithString:model.img3]];

            cell.titleLable.text=model.setname;
            cell.titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
            return cell;
        }else{
            ImgCell2 * cell=[tableView dequeueReusableCellWithIdentifier:@"cell2"];
            //        if (!cell) {
            //            cell=[[ImgCell2 alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell2"];
            //        }
            [cell.imgView1 sd_setImageWithURL:[NSURL URLWithString:model.img1]];
            [cell.imgView2 sd_setImageWithURL:[NSURL URLWithString:model.img2]];
            [cell.imgView3 sd_setImageWithURL:[NSURL URLWithString:model.img3]];
            cell.titleLable.text=model.setname;
            cell.titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];

            
            return cell;
        }
    }else{
        ImgCell * cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return WIDTH*0.587;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ImgModel * model=self.array[indexPath.row];
   
    
    PhotosetDetailController * photoVC=[[PhotosetDetailController alloc]init];
    NSString * strid = [NSString stringWithFormat:@"0096/%@",model.setid];
    photoVC.setid= strid;

    photoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:photoVC animated:YES];
   

    
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
