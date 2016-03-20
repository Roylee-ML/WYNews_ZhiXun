//
//  PlaySliderView.m
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "PlaySliderView.h"

#define kThumbTouchRectOffset   20

@interface PlaySliderView ()

@property (nonatomic, copy) PlaySliderViewAction touchBeganAction;
@property (nonatomic, copy) PlaySliderViewAction touchEndAction;
@property (nonatomic, copy) PlaySliderViewAction valueChangedAction;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation PlaySliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    // 只是在最后触发valuechange
    self.continuous = NO;
    
    self.bufferProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    _bufferProgress.progressTintColor = [UIColor colorWithHex:@"999999"];
    _bufferProgress.trackTintColor = [UIColor whiteColor];
    [self insertSubview:_bufferProgress atIndex:0];
    
    [self addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_bufferProgress setFrame:[self trackRectForBounds:self.bounds]];
}

- (void)addTouchBeganAction:(PlaySliderViewAction)touchBeganAction
{
    if (_touchBeganAction != touchBeganAction) {
        _touchBeganAction = touchBeganAction;
    }
}

- (void)addTouchEndAction:(PlaySliderViewAction)touchEndAction
{
    if (_touchEndAction != touchEndAction) {
        _touchEndAction = touchEndAction;
    }
}

- (void)addTouchValueChangedAction:(PlaySliderViewAction)valueChangedAction
{
    if (_valueChangedAction != valueChangedAction) {
        _valueChangedAction = valueChangedAction;
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    [_bufferProgress setProgress:progress animated:animated];
}

- (float)progress
{
    return _bufferProgress.progress;
}

#pragma mark - Action
- (void)progressSliderTouchBegan:(UISlider *)slider {
    _isDragging = YES;
    if (_touchBeganAction) {
        _touchBeganAction(self);
    }
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    _isDragging = NO;
    if (_touchEndAction) {
        _touchEndAction(self);
    }
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    if (_valueChangedAction) {
        _valueChangedAction(self);
    }
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect s_rect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    // 只增加上下的触摸范围
    s_rect.origin.y -= bounds.size.height/2;
    s_rect.size.height += bounds.size.height;
    
    return s_rect;
}

// 设定进度条的frame
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 10.0f;
    bounds.origin.y = (bounds.size.height - 2.0f)/2;
    bounds.size.height = 2.0f;
    bounds.size.width = bounds.size.width - 20.0f;
    return bounds;
}

- (CGRect)thumbRect
{
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds
                                      trackRect:trackRect
                                          value:self.value];
    return thumbRect;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
//    return CGRectContainsPoint([self thumbRect], point);
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * view = [super hitTest:point withEvent:event];
    //    CGRect thumbFrame = [self thumbRect];
    CGRect thumbFrame = self.bounds;
    
    // check if the point is within the thumb
    if (CGRectContainsPoint(thumbFrame, point))
    {
        // if so trigger the method of the super class
        NSLog(@"inside thumb");
        if ([view isKindOfClass:UIProgressView.class]) {
            return self;
        }
        return [super hitTest:point withEvent:event];
    }
    else
    {
        // if not just pass the event on to your superview
        NSLog(@"outside thumb");
        return [[self superview] hitTest:point withEvent:event];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _isMoving = NO;
    _isDragging = YES;
    if (self.touchBeganAction) {
        self.touchBeganAction(self);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    _isMoving = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _isDragging = NO;
    if (!_isMoving) {
        CGPoint location = [[touches allObjects].lastObject locationInView:self];
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        trackRect.size.height = self.bounds.size.height;
        trackRect.origin.y = 0;
        if (CGRectContainsPoint(trackRect, location)) {
            CGFloat minX = CGRectGetMinX(trackRect);
            CGFloat value = (location.x - minX)/CGRectGetWidth(trackRect);
            self.value = value;
            if (self.touchEndAction) {
                self.touchEndAction(self);
            }
            if (self.valueChangedAction) {
                self.valueChangedAction(self);
            }
        }
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _isDragging = NO;
}

@end



