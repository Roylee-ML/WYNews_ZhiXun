//
//  DiskAnimateView.h
//  WYNews
//
//  Created by 孟亮  on 15/6/14.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImgBlock)(UIImage* img);

@interface DiskAnimateView : UIView

@property (nonatomic,strong) UIImageView * diskImgView;


//开始旋转
-(void)startRotate;

//重制transform
-(void)resetTransfrom;

//继续旋转
-(void)playRotate;

//暂停旋转
-(void)pauseRotate;

//结束旋转时间
-(void)finishRotate;

//设置图片
-(void)setDiskImage:(UIImage*)img;

//获取图片
-(UIImage*)diskImage;

//添加改变图片
-(void)changeDiskImageWithUrl:(NSString*)url andHandle:(ImgBlock)handle;



@end
