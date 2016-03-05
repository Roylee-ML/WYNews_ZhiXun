//
//  DiskAnimateView.m
//  WYNews
//
//  Created by 孟亮  on 15/6/14.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "DiskAnimateView.h"
#import "UIImageView+WebCache.h"

@interface DiskAnimateView()

@property (nonatomic,strong) NSTimer * myTimer;

@end


@implementation DiskAnimateView

-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.frame = frame;
        
        //碟片边缘背景图片
        UIImageView * diskBgImgView = [[UIImageView alloc]initWithFrame:frame];
        diskBgImgView.image = [UIImage imageNamed:@"audio_bg_circle"];
        diskBgImgView.clipsToBounds = YES;
        diskBgImgView.contentMode = UIViewContentModeScaleAspectFill;
        diskBgImgView.layer.cornerRadius = diskBgImgView.frame.size.width/2;
        diskBgImgView.alpha = 0.7;
        diskBgImgView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:diskBgImgView];

        self.diskImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width*7.2/8, frame.size.height*7.2/8)];
        _diskImgView.center = self.center;
        _diskImgView.contentMode = UIViewContentModeScaleAspectFill;
        _diskImgView.clipsToBounds = YES;
        _diskImgView.layer.cornerRadius = _diskImgView.frame.size.width/2;
        
        [self addSubview:_diskImgView];
        
        [self setupTimer];
        
    }
    return self;
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
            _myTimer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:0.01 target:self selector:@selector(playRotateDisk) userInfo:nil repeats:YES];
            
            [[NSRunLoop currentRunLoop]addTimer:_myTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
            
#pragma mark ------- 这里必须先要开启时间然后再暂停，否则在线程之外控制时间会有无效情况--------
        
        }
    });
    
//    [_myTimer setFireDate:[NSDate distantFuture]];
}

-(void)playRotateDisk
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.diskImgView.transform = CGAffineTransformRotate(_diskImgView.transform, M_PI/720);
    });
}

//开始旋转
-(void)startRotate
{
    self.diskImgView.transform = CGAffineTransformIdentity;
    [_myTimer setFireDate:[NSDate date]];
}

//重制transform
-(void)resetTransfrom
{
    self.diskImgView.transform = CGAffineTransformIdentity;
}

//继续旋转
-(void)playRotate
{
    [_myTimer setFireDate:[NSDate date]];
}

//暂停旋转
-(void)pauseRotate
{
    [_myTimer setFireDate:[NSDate distantFuture]];
}

//结束旋转时间
-(void)finishRotate
{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}

//设置图片
-(void)setDiskImage:(UIImage*)img
{
    _diskImgView.image = img;
}

//获取图片
-(UIImage*)diskImage
{
    return _diskImgView.image;
}

//添加改变图片
-(void)changeDiskImageWithUrl:(NSString*)url andHandle:(ImgBlock)handle
{
    [_diskImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:HODER_IMG] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        handle(image);
    }];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
