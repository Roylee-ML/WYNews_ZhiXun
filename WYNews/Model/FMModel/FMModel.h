//
//  FMModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMSubModel.h"

@interface FMModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString * cname;    //板块标题
@property (nonatomic,strong) NSString * cid;      //板块cid
@property (nonatomic,strong) NSMutableArray * subModelArray; //板块内容model数组

@end
