//
//  UIGestureRecognizer+BlockAction.m
//  WYNews
//
//  Created by Roy lee on 16/3/17.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "UIGestureRecognizer+BlockAction.h"
static const void *UIGestureRecognizerBlockKey = &UIGestureRecognizerBlockKey;
static const void *UIGestureRecognizerShouldHandleActionKey = &UIGestureRecognizerShouldHandleActionKey;

@interface UIGestureRecognizer (BlocksInternal)

@property (nonatomic, assign) BOOL shouldHandleAction;

- (void)handleAction:(UIGestureRecognizer *)recognizer;

@end

@implementation UIGestureRecognizer (BlockAction)

+ (instancetype)recognizerWithAction:(UIGecognizerActionBlock)block
{
    return [[self.class alloc] initWithAction:block];
}

- (instancetype)initWithAction:(UIGecognizerActionBlock)block
{
    self = [self initWithTarget:self action:@selector(handleAction:)];
    if (!self) return nil;
    
    self.action = block;
    self.shouldHandleAction = YES;
    
    return self;
}

- (void)handleAction:(UIGestureRecognizer *)recognizer
{
    UIGecognizerActionBlock action = recognizer.action;
    if (!action) return;
    if (!self.shouldHandleAction) return;
    
    CGPoint location = [self locationInView:self.view];
    action(self, self.state, location);
    self.shouldHandleAction = YES;
}

- (void)setAction:(UIGecognizerActionBlock)action
{
    objc_setAssociatedObject(self, UIGestureRecognizerBlockKey, action, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIGecognizerActionBlock)action
{
    return objc_getAssociatedObject(self, UIGestureRecognizerBlockKey);
}

- (void)setShouldHandleAction:(BOOL)flag
{
    objc_setAssociatedObject(self, UIGestureRecognizerShouldHandleActionKey, @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)shouldHandleAction
{
    return [objc_getAssociatedObject(self, UIGestureRecognizerShouldHandleActionKey) boolValue];
}

- (void)cancel
{
    self.shouldHandleAction = NO;
}

@end

