//
//  ImgCell2.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgModel.h"
@interface ImgCell2 : UITableViewCell
@property(nonatomic,strong)ImgModel * imgModel;
//@property(nonatomic,strong)UIImageView * imgView1;
//@property(nonatomic,strong)UIImageView * imgView2;
//@property(nonatomic,strong)UIImageView * imgView3;
//@property(nonatomic,strong)UILabel * titleLable;
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;


@property (weak, nonatomic) IBOutlet UIImageView *imgView3;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@end
