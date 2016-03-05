//
//  HeadModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeadModel : NSObject<NSCoding>
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString * imgsrc;
@property(nonatomic,strong)NSString * url;
@end
