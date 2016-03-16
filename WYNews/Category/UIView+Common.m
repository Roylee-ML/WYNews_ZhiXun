//
//  UIView+Common.m
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)

CGFloat UIScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

CGSize UIScreenSize() {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}

CGRect UIScreenRect() {
    static CGRect bounds;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bounds = [UIScreen mainScreen].bounds;
    });
    return bounds;
}


- (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace {
    CGFloat lineH = 1.0/kScreenScale;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, pointY, self.bounds.size.width - (leftSpace + rightSpace), lineH)];
    lineView.backgroundColor = color;
    return lineView;
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace {
    [self removeViewWithTag:kTagLineViewUp];
    [self removeViewWithTag:kTagLineViewDown];
    CGFloat lineH = 1.0/kScreenScale;
    if (hasUp) {
        UIView *upView = [self lineViewWithPointYY:0 andColor:color andLeftSpace:leftSpace rightSpace:rightSpace];
        upView.tag = kTagLineViewUp;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [self lineViewWithPointYY:CGRectGetMaxY(self.bounds) - lineH andColor:color andLeftSpace:leftSpace rightSpace:rightSpace];
        downView.tag = kTagLineViewDown;
        [self addSubview:downView];
    }
}

- (void)removeViewWithTag:(NSInteger)tag {
    for (UIView *aView in [self subviews]) {
        if (aView.tag == tag) {
            [aView removeFromSuperview];
        }
    }
}


@end
