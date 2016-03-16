//
//  UIControl+BlockAction.m
//  WYNews
//
//  Created by Roy lee on 16/3/15.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "UIControl+BlockAction.h"

@import ObjectiveC.runtime;

static const void *UIControlHandlersKey = &UIControlHandlersKey;


#pragma mark Private

@interface UIControlWrapper : NSObject <NSCopying>

- (id)initWithAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic) UIControlEvents controlEvents;
@property (nonatomic, copy) void (^action)(id sender);

@end

@implementation UIControlWrapper

- (id)initWithAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents
{
    self = [super init];
    if (!self) return nil;
    
    self.action = action;
    self.controlEvents = controlEvents;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[UIControlWrapper alloc] initWithAction:self.action forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender
{
    self.action(sender);
}

@end





#pragma mark Category

@implementation UIControl (BlockAction)

- (void)addAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents
{
    NSParameterAssert(action);
    
    NSMutableDictionary *events = objc_getAssociatedObject(self, UIControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, UIControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSNumber *key = @(controlEvents);
    NSMutableSet *actions = events[key];
    if (!actions) {
        actions = [NSMutableSet set];
        events[key] = actions;
    }
    
    UIControlWrapper *target = [[UIControlWrapper alloc] initWithAction:action forControlEvents:controlEvents];
    [actions addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
}

- (void)removeActionForControlEvents:(UIControlEvents)controlEvents
{
    NSMutableDictionary *events = objc_getAssociatedObject(self, UIControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, UIControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSNumber *key = @(controlEvents);
    NSSet *actions = events[key];
    
    if (!actions)
        return;
    
    [actions enumerateObjectsUsingBlock:^(id sender, BOOL *stop) {
        [self removeTarget:sender action:NULL forControlEvents:controlEvents];
    }];
    
    [events removeObjectForKey:key];
}

- (BOOL)hasActionsForControlEvents:(UIControlEvents)controlEvents
{
    NSMutableDictionary *events = objc_getAssociatedObject(self, UIControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, UIControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSNumber *key = @(controlEvents);
    NSSet *actions = events[key];
    
    if (!actions)
        return NO;
    
    return !!actions.count;
}

@end

