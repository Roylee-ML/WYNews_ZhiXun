//
//  FunModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunModel : NSObject<NSCoding>


@property(nonatomic,strong)NSString * boardid;
@property(nonatomic,strong)NSString * digest;
@property(nonatomic,strong)NSString * docid;
@property(nonatomic,strong)NSString * downTimes;
@property(nonatomic,strong)NSString * img;
@property(nonatomic,strong)NSString * imgsrc;
@property(nonatomic,strong)NSString * picCount;
@property(nonatomic,strong)NSString * pixel;
@property(nonatomic,strong)NSString * replyid;
@property(nonatomic,strong)NSString * source;
@property(nonatomic,strong)NSString * title;
@property(nonatomic,strong)NSString * upTimes;
@end
