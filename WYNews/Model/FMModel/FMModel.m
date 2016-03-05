//
//  FMModel.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMModel.h"

@implementation FMModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"tList"]) {
        NSArray * array = value;
        self.subModelArray = [NSMutableArray array];
        for (NSDictionary * dic in array) {
            FMSubModel * model = [[FMSubModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [_subModelArray addObject:model];
        }
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
