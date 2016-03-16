//
//  MilitaryTableViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CostomCell.h"
#import "ImageCell.h"
#import "DataModel.h"
#import "UIImageView+WebCache.h"
#import "CommonDetailViewController.h"
#import "PhotosetDetailController.h"

@interface MilitaryTableViewController : UITableViewController
@property(nonatomic,strong) NSMutableArray * array;
@property(nonatomic,strong) NSMutableArray * oneArray;//存储第一个model
@end
