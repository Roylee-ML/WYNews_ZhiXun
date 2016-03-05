//
//  CustView.h
//  haha
//
//  Created by lanou3g on 15/6/3.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustView : UIScrollView <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIImageView *imageView;

//视图滚动后恢复大小重置frame
-(void)resetFrame;

@end
