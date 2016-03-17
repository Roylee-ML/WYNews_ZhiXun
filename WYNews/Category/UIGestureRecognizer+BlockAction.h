//
//  UIGestureRecognizer+BlockAction.h
//  WYNews
//
//  Created by Roy lee on 16/3/17.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIGecognizerActionBlock)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location);

@interface UIGestureRecognizer (BlockAction)

+ (instancetype)recognizerWithAction:(UIGecognizerActionBlock)block;

- (instancetype)initWithAction:(UIGecognizerActionBlock)block;

@end
