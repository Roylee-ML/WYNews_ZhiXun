//
//  RootTabBarViewController.m
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "RootTabBarViewController.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBar.translucent = NO;
    
    [self.tabBar setBackgroundImage:[[UIImage imageNamed:@"tabBar_bg"] imageWithColor:[UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1]]];
    
//    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, TABBAR_HEIGHT)];
//    view.backgroundColor = [UIColor colorWithRed:250.0/255 green:0 blue:210.0/255 alpha:1];
//    
//    [self.tabBar insertSubview:view atIndex:0];
    
    [self setupViews];
}

-(void)setupViews
{
    NewsViewController * newsVC = [[NewsViewController alloc]init];
    UINavigationController * newsNC = [[UINavigationController alloc]initWithRootViewController:newsVC];
    newsNC.tabBarItem.title = @"新闻";
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:197.0/255 green:193.0/255 blue:170.0/255 alpha:1];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    [newsNC.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [newsNC.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    newsNC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_news"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newsNC.tabBarItem.selectedImage = [[[UIImage imageNamed:@"tabbar_news"]imageWithColor:[UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    VideoViewController * videoVC = [[VideoViewController alloc]init];
    VideoPlayControler * videoVC = [[VideoPlayControler alloc]init];
    UINavigationController * videoNC = [[UINavigationController alloc]initWithRootViewController:videoVC];
    videoNC.tabBarItem.title = @"视频";
    NSMutableDictionary *textAttrs1 = [NSMutableDictionary dictionary];
    textAttrs1[NSForegroundColorAttributeName] = [UIColor colorWithRed:197.0/255 green:193.0/255 blue:170.0/255 alpha:1];
    NSMutableDictionary *selectTextAttrs1 = [NSMutableDictionary dictionary];
    selectTextAttrs1[NSForegroundColorAttributeName] = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    [videoNC.tabBarItem setTitleTextAttributes:textAttrs1 forState:UIControlStateNormal];
    [videoNC.tabBarItem setTitleTextAttributes:selectTextAttrs1 forState:UIControlStateSelected];
    videoNC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_video"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    videoNC.tabBarItem.selectedImage = [[[UIImage imageNamed:@"tabbar_video"]imageWithColor:[UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    FMViewController * fmVC = [[FMViewController alloc]init];
    UINavigationController * fmNC = [[UINavigationController alloc]initWithRootViewController:fmVC];
    fmNC.tabBarItem.title = @"电台";
    NSMutableDictionary *textAttrs2 = [NSMutableDictionary dictionary];
    textAttrs2[NSForegroundColorAttributeName] = [UIColor colorWithRed:197.0/255 green:193.0/255 blue:170.0/255 alpha:1];
    NSMutableDictionary *selectTextAttrs2 = [NSMutableDictionary dictionary];
    selectTextAttrs2[NSForegroundColorAttributeName] = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    [fmNC.tabBarItem setTitleTextAttributes:textAttrs2 forState:UIControlStateNormal];
    [fmNC.tabBarItem setTitleTextAttributes:selectTextAttrs2 forState:UIControlStateSelected];
    fmNC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_audio"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fmNC.tabBarItem.selectedImage = [[[UIImage imageNamed:@"tabbar_audio"]imageWithColor:[UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    MineTableViewController * mineTBV = [[MineTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    UINavigationController * mineNC = [[UINavigationController alloc]initWithRootViewController:mineTBV];
//    mineNC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我的" image:[UIImage imageNamed:@""] selectedImage:[UIImage imageNamed:@""]];
    
    
    self.viewControllers = @[newsNC,videoNC,fmNC];
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
