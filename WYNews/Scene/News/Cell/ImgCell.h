//
//  ImgCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgModel.h"
@interface ImgCell : UITableViewCell
@property(nonatomic,strong)ImgModel * imgModel;
//@property(nonatomic,strong)UIImageView * imgView;
//@property(nonatomic,strong)UILabel * titleLable;
@property (weak, nonatomic) IBOutlet UIImageView *imgeView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
