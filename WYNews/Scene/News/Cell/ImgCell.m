//
//  ImgCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ImgCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation ImgCell


//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        //创建imgView存放图片
//        self.imgView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 365, 175)];
//        //创建标题lable
//        self.titleLable=[[UILabel alloc]initWithFrame:CGRectMake(5, 185, 365, 30)];
//        [self.contentView addSubview:self.imgView];
//        [self.contentView addSubview:self.titleLable];
//    }
//    return self;
//}
//




- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
