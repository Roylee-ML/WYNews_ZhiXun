//
//  NSString+StringHeight.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "NSString+StringHeight.h"

@implementation NSString (StringHeight)

+(CGFloat)textLableWideth:(NSString*)text andFont:(UIFont*)font
{
    //iOS 7.0之后计算高度使用到的方法。它返回一个矩形区域
    //限定宽高（高基本没用）,在限定宽高内显示文字。
    CGSize size=CGSizeMake(200, 15);
    //将字体与字体大小存放到字典中
    NSDictionary *dic=@{NSFontAttributeName:font};
    CGRect rect=[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return rect.size.width;
}

//转换播放时间
+(NSString*)convertTime:(NSTimeInterval)time
{
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formater = [[NSDateFormatter alloc]init];
    if (time/3600 >=1) {
        [formater setDateFormat:@"HH:mm:ss"];
    }else{
        [formater setDateFormat:@"mm:ss"];
    }
    
    NSString * newTimeStr = [formater stringFromDate:date];
    
    return newTimeStr;
}

+(NSMutableAttributedString*)stringHigehtBy:(CGFloat)height withString:(NSString*)text
{
    NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc]initWithString:text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:height];
    [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    return attributeStr;
}


@end
