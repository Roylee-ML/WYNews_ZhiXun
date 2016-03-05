//
//  FunnyTableViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunModel.h"
#import "FunnyCell.h"
#import "UIImageView+WebCache.h"
#import "FunnyImageCell.h"
#import "SDRefresh.h"
@interface FunnyTableViewController : UITableViewController
@property(nonatomic,strong) NSMutableArray * array;

@end
