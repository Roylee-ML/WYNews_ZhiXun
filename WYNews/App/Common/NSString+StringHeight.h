//
//  NSString+StringHeight.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringHeight)

//获取一定文本的宽度
+(CGFloat)textLableWideth:(NSString*)text andFont:(UIFont*)font;

//转换播放时间
+(NSString*)convertTime:(NSTimeInterval)time;

//自定义lable的文本间距
+(NSMutableAttributedString*)stringHigehtBy:(CGFloat)height withString:(NSString*)text;

@end
