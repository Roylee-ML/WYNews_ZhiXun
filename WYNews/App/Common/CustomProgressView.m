//
//  CustomProgressView.m
//  WYNews
//
//  Created by lanou3g on 15/6/9.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CustomProgressView.h"

@interface CustomProgressView()

@property (nonatomic,strong) UIImageView * imgView;

@end

@implementation CustomProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.frame = frame;
        self.imgView = [[UIImageView alloc]initWithFrame:frame];
        _imgView.clipsToBounds = YES;
//        _imgView.image = [UIImage imageNamed:@"jindu"];
        _imgView.backgroundColor = [UIColor lightGrayColor];
        
        UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width/4, frame.size.width/8)];
        title.backgroundColor = [UIColor whiteColor];
        title.layer.borderColor = [UIColor blackColor].CGColor;
        title.layer.borderWidth = 0.2;
        title.text = @"当前网络不给力，请下拉刷新！";
        title.textAlignment = NSTextAlignmentCenter;
        title.center = self.center;
        
        [self addSubview:_imgView];
        
        [self addSubview:title];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
