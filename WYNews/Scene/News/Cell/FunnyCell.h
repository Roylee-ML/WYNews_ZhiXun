//
//  FunnyCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunModel.h"
@interface FunnyCell : UITableViewCell
@property(nonatomic,strong)UILabel * digestLable;
@property(nonatomic,strong)UIImageView * imgView;
@property(nonatomic,strong)FunModel * model;
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
+(CGFloat )textLableHeight:(NSString *)text;
@end
