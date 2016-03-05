//
//  ImgeCell1.h
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgModel.h"
@interface ImgeCell1 : UITableViewCell

@property(nonatomic,strong)ImgModel * imgModel;
//@property(nonatomic,strong)UIImageView * imgView1;
//@property(nonatomic,strong)UIImageView * imgView2;
//@property(nonatomic,strong)UIImageView * imgView3;
//@property(nonatomic,strong)UILabel * titleLable;

@property (weak, nonatomic) IBOutlet UIImageView *imgView1;

@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@property (weak, nonatomic) IBOutlet UIImageView *imgView3;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@end
