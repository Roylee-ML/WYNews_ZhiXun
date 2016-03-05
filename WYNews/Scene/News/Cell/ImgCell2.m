//
//  ImgCell2.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ImgCell2.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation ImgCell2

//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        //创建imgView存放图片
//        self.imgView1=[[UIImageView alloc]initWithFrame:CGRectMake(0.013*WIDTH, 0.013*WIDTH, 0.2533*WIDTH, 0.24*WIDTH)];
//        self.imgView2=[[UIImageView alloc]initWithFrame:CGRectMake(0.013*WIDTH, 0.2667*WIDTH, 0.2533*WIDTH, 0.24*WIDTH)];
//        self.imgView3=[[UIImageView alloc]initWithFrame:CGRectMake(0.28*WIDTH, 0.013*WIDTH, 0.7066*WIDTH, 0.4933*WIDTH)];
//        //创建标题lable
//        self.titleLable=[[UILabel alloc]initWithFrame:CGRectMake(0.013*WIDTH, 0.5066*WIDTH, 0.96*WIDTH, 0.08*WIDTH)];
//        //添加到cell上
//        [self.contentView addSubview:self.imgView3];
//        [self.contentView addSubview:self.imgView2];
//        [self.contentView addSubview:self.imgView1];
//        [self.contentView addSubview:self.titleLable];
//    }
//    return self;
//}
//
//






- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
