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

#pragma mark gesturerecognizer state
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchBlock) {
        self.touchBlock(self, UI_GestureRecognizerStateBegan, touches, event);
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchBlock) {
        self.touchBlock(self, UI_GestureRecognizerStateMoved, touches, event);
    }else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchBlock) {
        self.touchBlock(self, UI_GestureRecognizerStateEnded, touches, event);
    }else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchBlock) {
        self.touchBlock(self, UI_GestureRecognizerStateCancelled, touches, event);
    }else {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void (^)(UIView *view, UI_GestureRecognizerState state, NSSet *touches, UIEvent *event))touchBlock {
    return objc_getAssociatedObject(self, "touch_block");
}

- (void)setTouchBlock:(void (^)(UIView *, UI_GestureRecognizerState, NSSet *, UIEvent *))touchBlock {
    [self willChangeValueForKey:@"_touchBlock"];
    objc_setAssociatedObject(self, "touch_block", touchBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"_touchBlock"];
}



- (void)doCircleFrame{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithHex:@"0xdddddd"].CGColor;
}
- (void)doNotCircleFrame{
    self.layer.cornerRadius = 0.0;
    self.layer.borderWidth = 0.0;
}

- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = kScreenScale;
    if (width == 0) {
        return;
    }
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor colorWithHex:@"0xdddddd"].CGColor;
    }else{
        self.layer.borderColor = color.CGColor;
    }
}

#pragma mark - UIGestureRecognizerBlock
- (UIGestureRecognizer *)addGestureRecognizer:(Class)gesClass action:(UIGecognizerActionBlock)action {
    if (![gesClass isSubclassOfClass:UIGestureRecognizer.class]) {
        return nil;
    }
    UIGestureRecognizer * ges = [(UIGestureRecognizer *)[gesClass alloc] initWithAction:action];
    [self addGestureRecognizer:ges];
    return ges;
}


@end
