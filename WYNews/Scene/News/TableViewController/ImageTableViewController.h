//
//  ImageTableViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgModel.h"
#import "ImgCell.h"
//#import "ImgCell1.h"
#import "ImgCell2.h"
#import "ImgeCell1.h"
#import "UIImageView+WebCache.h"
#import "SDRefresh.h"
#import "PhotosetDetailController.h"
@interface ImageTableViewController : UITableViewController
@property(nonatomic,strong) NSMutableArray * array;
@end
