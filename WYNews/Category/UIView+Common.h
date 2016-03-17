//
//  UIView+Common.h
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGestureRecognizer+BlockAction.h"

#define kTagLineViewUp    1007
#define kTagLineViewDown  1008

/// State of the gesture
typedef NS_ENUM(NSUInteger, UI_GestureRecognizerState) {
    UI_GestureRecognizerStateBegan, ///< gesture start
    UI_GestureRecognizerStateMoved, ///< gesture moved
    UI_GestureRecognizerStateEnded, ///< gesture end
    UI_GestureRecognizerStateCancelled, ///< gesture cancel
};

@interface UIView (Common)

CGFloat UIScreenScale();
CGSize UIScreenSize();
CGRect UIScreenRect();

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;

- (UIGestureRecognizer *)addGestureRecognizer:(Class)gesClass action:(UIGecognizerActionBlock)action;

/**
 touch block for easy handle. eg.
 
    UIView * eg_view = [UIView new];
    [eg_view setTouchBlock:^(UIView * view, UI_GestureRecognizerState state, NSSet * touches, UIEvent * event) {
        // set backgroundcolor for different gesture state
        if (state == UI_GestureRecognizerStateBegan) {
            weak_self.timeLable.backgroundColor = [UIColor grayColor];    // color for highlighted
        }else {
            weak_self.timeLable.backgroundColor = [UIColor whiteColor];   // color for normal
        }
    }];
 */
@property (nonatomic, copy) void (^touchBlock)(UIView *view, UI_GestureRecognizerState state, NSSet *touches, UIEvent *event);

@end
