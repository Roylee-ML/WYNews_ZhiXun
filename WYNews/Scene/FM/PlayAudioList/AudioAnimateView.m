//
//  AudiioAnimateView.m
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "AudioAnimateView.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width

@interface AudioAnimateView()

@property (nonatomic,strong) NSArray * imagesArray;
@property (nonatomic,strong) UIImageView * imgView;

@end

@implementation AudioAnimateView

//静态变量标记播放下标
static NSInteger p_index = 0;

-(instancetype)initWithFrame:(CGRect)frame andImages:(NSArray*)imagesArray
{
    if ([super initWithFrame:frame]) {
        self.frame = frame;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        [self p_setupViewsWithImages:imagesArray];
        [self setupTimer];
    }
    return self;
}

-(void)p_setupViewsWithImages:(NSArray*)imgsArray
{
    self.imagesArray = imgsArray;
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self addSubview:_imgView];
    
    self.imgView.image = (UIImage*)imgsArray[0];
    
    p_index = 0;
    
}

-(void)setupTimer
{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue = dispatch_queue_create("com.mengliang.zhixunxinwen", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        @autoreleasepool {
            _myTimer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:0.4 target:self selector:@selector(playAnmateView) userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop]addTimer:_myTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
            
#pragma mark ------- 这里必须先要开启时间然后再暂停，否则在线程之外控制时间会有无效情况--------
            
//            [_myTimer setFireDate:[NSDate distantFuture]];
        }
    });
    self.isAnimating = YES;
}

-(void)playAnmateView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (p_index<_imagesArray.count) {
            self.imgView.image = (UIImage*)_imagesArray[p_index];
        }else{
            self.imgView.image = (UIImage*)_imagesArray[0];
            p_index = 0;
        }
        p_index ++;
//        NSLog(@"++++++++++++++++++++++++++++++++++++play");
    });
}

//播放
-(void)animate
{
    if (!_isAnimating) {
        [_myTimer setFireDate:[NSDate date]];
        _isAnimating = YES;
    }
}

//暂停
-(void)stopAnimate
{
    if (_isAnimating) {
        [_myTimer setFireDate:[NSDate distantFuture]];
        _isAnimating = NO;
    }
}

//重置出事化并暂停动画image
-(void)resetAnimateAndPause
{
    [_myTimer setFireDate:[NSDate distantFuture]];
    _isAnimating = NO;
    self.imgView.image = _imagesArray[0];
    p_index = 0;
}

//切换父视图
-(void)exchangerSuperViewTo:(UIView*)secondView
{
    [self stopAnimate];
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    [secondView addSubview:self];
    
    self.center = CGPointMake(self.center.x, SELF_WIDTH*1.0/12);
    
    self.imgView.image = _imagesArray[0];
    p_index = 0;
}

//移除
-(void)removeAnimate
{
    [self removeFromSuperview];
    if (self.myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}


/*
 //布局视图
 -(void)animatWithOrder:(AnimateRequest)request
 {
 switch (request) {
 case 0:
 [_myTimer setFireDate:[NSDate date]];
 self.isAnimating = YES;
 break;
 case 1:
 [_myTimer setFireDate:[NSDate distantFuture]];
 self.imgView.image = (UIImage*)_imagesArray[0];
 self.isAnimating = NO;
 break;
 default:
 break;
 }
 //    NSLog(@"-------timer ==== %@",_myTimer);
 }
 */


-(void)dealloc
{
    [_myTimer invalidate];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
