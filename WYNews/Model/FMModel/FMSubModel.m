//
//  FMSubModel.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMSubModel.h"

@implementation FMSubModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"radio"]) {
        NSDictionary * dic = value;
        
        _docid = dic[@"docid"];
        _title = dic[@"title"];
        _imgsrc = dic[@"imgsrc"];
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
