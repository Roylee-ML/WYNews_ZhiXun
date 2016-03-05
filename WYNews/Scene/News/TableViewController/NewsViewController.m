//
//  NewsViewController.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "NewsViewController.h"
#import "OnePlayer.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CustomTableViewController * headTVC=[[CustomTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
    
    SCNavTabBarController * navTabBarController=[[SCNavTabBarController alloc]init];
    navTabBarController.subViewControllers=[NSMutableArray arrayWithArray:@[headTVC]];
    
    navTabBarController.titles = [@[@"头 条",@"图 片",@"时 尚",@"军 事",@"情 感",@"读 书",@"段 子",@"娱 乐"] mutableCopy];
    
    
    navTabBarController.showArrowButton=YES;
    [navTabBarController addParentController:self];
    
    //设置自定义导航栏
    [[PersistManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@"title1"] andBGImg:[UIImage imageNamed:NC_IMG]];

    
    // Do any additional setup after loading the view from its nib.

/*
    NSArray * familyName = [UIFont familyNames];
    for (NSString * family in familyName) {
        NSLog(@"family =============== %@",family);
        NSArray * fonts = [UIFont fontNamesForFamilyName:family];
        for (NSString * font in fonts) {
            NSLog(@"font ================ %@",font);
        }
    }
*/
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPlayingAudioVC:) name:BackAudioMark object:nil];
}

-(void)pushPlayingAudioVC:(NSNotification*)notification
{
    [[OnePlayer onePlayer]playAudioFromController:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
