//
//  CostomCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
@interface CostomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *digestLable;

@property(nonatomic,strong)DataModel * model;
@end
