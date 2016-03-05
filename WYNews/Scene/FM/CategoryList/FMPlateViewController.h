//
//  FMPlateViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMPlayListViewController.h"
#import "FMCateListTableViewCell.h"

typedef void(^ShowBarBlock)();

@interface FMPlateViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,ShowPlayingAudio>

@property (nonatomic,strong) ShowBarBlock block;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) FMModel * model;

@end
