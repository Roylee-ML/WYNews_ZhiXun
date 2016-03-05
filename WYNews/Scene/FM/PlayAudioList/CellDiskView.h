//
//  CellDiskView.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMSubModel.h"
#import "UIImageView+WebCache.h"

typedef void(^EnterPlayBlock)(NSString*);

@interface CellDiskView : UIView

@property (nonatomic,copy) EnterPlayBlock block;
@property (nonatomic,strong) FMSubModel * model;

@end
