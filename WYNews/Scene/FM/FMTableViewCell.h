//
//  FMTableViewCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMModel.h"
#import "CellDiskView.h"

typedef void(^EnterBlock)(NSString * cid);

@interface FMTableViewCell : UITableViewCell

@property (nonatomic,copy) EnterBlock enterBlock;
@property (nonatomic,strong) FMModel * fm_model;

//通过下标设置标题图片
-(void)setupImageForTitleAtindex:(NSInteger)index;

@end
