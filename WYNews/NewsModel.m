//
//  HeadLineModel.m
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "NewsModel.h"

@implementation NewsModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"photosetID"]) {
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]];
        value = [value substringFromIndex:4];
        self.photosetID = value;
    }
    if ([key isEqualToString:@"imgextra"]) {
        NSArray * array = value;
        self.imgArray[1] = array[0];
        self.imgArray[2] = array[1];
    }
    if ([key isEqualToString:@"imgsrc"]) {
        self.imgArray[0] = value;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //属性自动编码
    [self autoEncodeWithCoder:aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init]) {
        //属性自动解码
        [self autoDecode:aDecoder];
    }
    return self;
}

//懒加载数组属性
-(NSMutableArray *)imgArray
{
    if (!_imgArray) {
        _imgArray = [NSMutableArray array];
    }
    return _imgArray;
}


@end
