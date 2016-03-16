//
//  NSString+Common.h
//  StarProject
//
//  Created by Roy lee on 15/12/16.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (BOOL)isEmpty;

- (NSString *)pinYinString;

// 字符串中的单词首字母大写
- (NSString *)capitalPinYinString;

@end
