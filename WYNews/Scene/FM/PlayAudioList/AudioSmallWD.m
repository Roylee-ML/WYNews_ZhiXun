//
//  AudioSmallWD.m
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "AudioSmallWD.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height

@interface AudioSmallWD()
{
    NSString * _title;
}
@end

@implementation AudioSmallWD

-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithRed:252.0/255 green:252.0/255 blue:238.0/255 alpha:1];
        
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        
        [self setupViews];
    }
    return self;
}

-(void)setupViews
{
//    UIImageView * bgImgView = [[UIImageView alloc]initWithFrame:self.frame];
//    bgImgView.backgroundColor = [UIColor whiteColor];
    
    self.playImgView = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_EDGE, STATUS_HEIGHT/5, STATUS_HEIGHT*4/5-2, STATUS_HEIGHT*4/5-2)];
    _playImgView.image = [[UIImage imageNamed:@"bofang"]imageWithColor:[UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1]];
    
    [self addSubview:_playImgView];
    
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_EDGE + STATUS_HEIGHT,STATUS_HEIGHT/5-1, SELF_WIDTH*4/5, STATUS_HEIGHT*4/5)];
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.font = [UIFont systemFontOfSize:10];
    _titleLable.text = @"正在播放.........";
    _titleLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    
    [self addSubview:_titleLable];
    
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, 1)];
    _progress.progressTintColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    _progress.trackTintColor = [UIColor clearColor];
    
    [self addSubview:_progress];
    
    //创建button点击事件
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = self.frame;
    button.backgroundColor = [UIColor clearColor];
    
    [button addTarget:self action:@selector(backToAudio) forControlEvents:UIControlEventTouchUpInside];
    
//    [self addSubview:bgImgView];
    [self addSubview:button];
}

-(void)showWindowWithMessage:(NSString*)title
{
//    _title = title;
    
    self.hidden = NO;
    self.alpha = 1.0;
    
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, totalSize.width, 0 };
    
    __weak AudioSmallWD * sself = self;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = (CGRect){self.frame.origin, totalSize };
    } completion:^(BOOL finished){
        sself.titleLable.text = title;
    }];
}

-(void)showWindow
{
    self.hidden = NO;
    self.alpha = 1.0;
    
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, totalSize.width, 0 };
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = (CGRect){self.frame.origin, totalSize };
    } completion:^(BOOL finished){
        
    }];
}

- (void)hideWindow
{
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
//        sself.titleLable.text = @"";
        self.hidden = YES;
    }];
}


-(void)backToAudio
{
    //通知实现回跳播放音频
    [[NSNotificationCenter defaultCenter]postNotificationName:BackAudioMark object:nil];
    
//    //协议方式实现
//    if ([[PersistManger defoutManger].showDelegate respondsToSelector:@selector(showPlayingAudioAndHidenSmallWindow)]) {
//        [[PersistManger defoutManger].showDelegate showPlayingAudioAndHidenSmallWindow];
//    }
    
    NSLog(@"点击状态栏.......");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
