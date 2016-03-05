//
//  DataModel.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel


-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
-(void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"photosetID"]) {
        
//        NSLog(@"setid ===== %@",value);
        
        if ([value length]>10) {
            value = [value stringByReplacingOccurrencesOfString:@"|" withString:@"/"];
            value = [value substringFromIndex:4];
        }
        
        self.photosetID = value;
    }
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
