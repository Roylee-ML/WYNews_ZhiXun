//
//  UIControl+BlockAction.h
//  WYNews
//
//  Created by Roy lee on 16/3/15.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (BlockAction)

- (void)addAction:(void (^)(id sender))action forControlEvents:(UIControlEvents)controlEvents;

- (void)removeActionForControlEvents:(UIControlEvents)controlEvents;

- (BOOL)hasActionsForControlEvents:(UIControlEvents)controlEvents;

@end
