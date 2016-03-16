//
//  UIView+Common.h
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTagLineViewUp    1007
#define kTagLineViewDown  1008

@interface UIView (Common)

CGFloat UIScreenScale();
CGSize UIScreenSize();
CGRect UIScreenRect();

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;

@end
