//
//  VideoModel.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    
    if ([key isEqualToString:@"mp4_url"]) {
        self.mp4_url = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
