//
//  UIColor+HexColor.h
//  WYNews
//
//  Created by Roy lee on 16/3/15.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (HexColor)

@property (nonatomic, assign, readonly) CGFloat red;

@property (nonatomic, assign, readonly) CGFloat green;

@property (nonatomic, assign, readonly) CGFloat blue;

@property (nonatomic, assign, readonly) CGFloat alpha;

+ (UIColor *)colorWithHex:(NSString *)hex;

- (NSString *)hexValue;

- (NSString *)hexValueWithAlpha:(BOOL)includeAlpha;

@end
