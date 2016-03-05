//
//  FMPlayingModel.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMPlayingModel.h"

@implementation FMPlayingModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"video"]) {
        NSArray * array = value;
        NSDictionary * dic = (NSDictionary*)array[0];
        _cover = dic[@"cover"];
        _url_mp4 = dic[@"url_mp4"];
        _size = dic[@"size"];
    }
    if ([key isEqualToString:@"ptime"]) {
        _ptime = [value substringToIndex:11];
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [self autoEncodeWithCoder:aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super init]) {
        [self autoDecode:aDecoder];
    }
    return self;
}

@end
