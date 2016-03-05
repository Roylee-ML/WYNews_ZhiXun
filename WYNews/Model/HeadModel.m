//
//  HeadModel.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "HeadModel.h"

@implementation HeadModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
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


@end
