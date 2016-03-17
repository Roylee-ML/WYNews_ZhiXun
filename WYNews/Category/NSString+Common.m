//
//  NSString+Common.m
//  StarProject
//
//  Created by Roy lee on 15/12/16.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        resultSize = [self boundingRectWithSize:size
                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil].size;
    } else {
        resultSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    resultSize = CGSizeMake(MIN(size.width, ceilf(resultSize.width)), MIN(size.height, ceilf(resultSize.height)));
    return resultSize;
}

- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    return [self getSizeWithFont:font constrainedToSize:size].height;
}
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    return [self getSizeWithFont:font constrainedToSize:size].width;
}

- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmpty
{
    return [[self trimWhitespace] isEqualToString:@""];
}

- (NSString *)pinYinString
{
    if ([self length]) {
        NSMutableString *pyStr = [[NSMutableString alloc] initWithString:self];
        if (CFStringTransform((__bridge CFMutableStringRef)pyStr, 0, kCFStringTransformMandarinLatin, NO)) {
            NSLog(@"pinyin: %@", pyStr);
        }
        if (CFStringTransform((__bridge CFMutableStringRef)pyStr, 0, kCFStringTransformStripDiacritics, NO)) {
            NSLog(@"pinyin: %@", pyStr);
        }
        return pyStr;
    }
    return self;
}

// 字符串中的单词首字母大写
- (NSString *)capitalPinYinString
{
    if ([self length]) {
        NSMutableString *pyStr = [[NSMutableString alloc] initWithString:self];
        if (CFStringTransform((__bridge CFMutableStringRef)pyStr, 0, kCFStringTransformMandarinLatin, NO)) {
            NSLog(@"pinyin: %@", pyStr);
        }
        if (CFStringTransform((__bridge CFMutableStringRef)pyStr, 0, kCFStringTransformStripDiacritics, NO)) {
            NSLog(@"pinyin: %@", pyStr);
        }
        return [pyStr capitalizedString];
    }
    return self;
}

+ (NSString *)formatterNumberString:(NSInteger)number
{
    NSString * numStr = nil;
    if (number > 1000*1000*10) {
        numStr = [NSString stringWithFormat:@"%.1f亿",number/(1000*1000*10.0)];
    }else if (number > 1000*10) {
        numStr = [NSString stringWithFormat:@"%.1f万",number/(1000*10.0)];
    }
    return numStr;
}

@end
