//
//  ImageCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "ImageCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation ImageCell




//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        
//        self.imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0.0133*WIDTH, 0.0133*WIDTH, (WIDTH-4*0.0133*WIDTH)/3.0, 0.24*WIDTH )];
//        self.imgView1=[[UIImageView alloc]initWithFrame:CGRectMake((WIDTH-4*0.0133*WIDTH)/3.0+0.0133*WIDTH*2, 0.0133*WIDTH, (WIDTH-4*0.0133*WIDTH)/3.0, 0.24*WIDTH)];
//        self.imgView2=[[UIImageView alloc]initWithFrame:CGRectMake(2*(WIDTH-4*0.0133*WIDTH)/3.0+0.0133*WIDTH*3, 0.0133*WIDTH, (WIDTH-4*0.0133*WIDTH)/3.0, 0.24*WIDTH)];
//        
//        [self.contentView addSubview:self.imgView];
//        [self.contentView addSubview:self.imgView1];
//        [self.contentView addSubview:self.imgView2];
//        
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
