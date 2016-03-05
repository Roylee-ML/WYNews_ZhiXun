//
//  AllowPanBack.m
//  WYNews
//
//  Created by 孟亮  on 15/7/8.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "AllowPanBackScrollView.h"

@implementation AllowPanBackScrollView


-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    NSArray * subViews = self.subviews;
//    for (UIView * subV in subViews) {
//        if ([subV isKindOfClass:[UIScrollView class]]) {
//            UIScrollView * sub = (UIScrollView*)subV;
//            if (sub.zoomScale > 1) {
//                if (sub.contentOffset.x == 0 || (sub.contentOffset.x + sub.frame.size.width + 1) >= sub.contentSize.width) {
//                    return YES;
//                }else{
//                    return NO;
//                }
//            }
//        }
//    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer * pan = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint location = [pan locationInView:self];
        if (location.x < 30) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

@end
