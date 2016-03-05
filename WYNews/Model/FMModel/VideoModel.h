//
//  VideoModel.h
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NSCoding.h"

@interface VideoModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString * title;      //标题，描述
@property (nonatomic,strong) NSString * cover;      //封面图片URL
@property (nonatomic,strong) NSString * mp4_url;    //MP4视频URL
@property (nonatomic,assign) int replyCount;  //跟帖人数
@property (nonatomic,assign) int playCount;   //播放次数
@property (nonatomic,assign) int length;      //时长
@property (nonatomic,strong) NSString * ptime;      //更新时间
@property (nonatomic,strong) NSString * replyid;

@end
