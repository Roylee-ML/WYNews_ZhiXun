
//
//  NewsDetailModel.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "NewsDetailModel.h"

@implementation NewsDetailModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //其余属性自动编码
    [self autoEncodeWithCoder:aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init]) {
        //其余属性自动解码
        [self autoDecode:aDecoder];
    }
    return self;
}


//-(NSAttributedString * )attributedText:(NSString *)text
//{
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:text];
//     NSString * strongPattern = @"<strong>[\\u4e00-\\u9fa5]+</strong>";
//    [text enumerateStringsMatchedByRegex:strongPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIFont systemFontOfSize:18] range:*capturedRanges];
//    } ];
//    return attributedText;
//
//}






























@end
