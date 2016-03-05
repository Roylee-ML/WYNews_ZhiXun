//
//  FMCateListTableViewCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+StringHeight.h"
#import "FMSubModel.h"
#import "UIImageView+WebCache.h"


@interface FMCateListTableViewCell : UITableViewCell

@property (nonatomic,strong) FMSubModel * model;
@property (nonatomic,strong) UIImageView * headImgView;

@end
