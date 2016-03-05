//
//  FMSubModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMSubModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString * tname;       //标题
@property (nonatomic,assign) int playCount;    //播放次数
@property (nonatomic,strong) NSString * docid;       //播放id
@property (nonatomic,strong) NSString * title;       //内容描述
@property (nonatomic,strong) NSString * imgsrc;      //图片网址

@end
