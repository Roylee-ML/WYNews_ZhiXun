//
//  FMPlayingModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMPlayingModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString * source;  //音乐来源
@property (nonatomic,strong) NSString * cover;   //封面图片
@property (nonatomic,strong) NSString * url_mp4; //音乐网址
@property (nonatomic,strong) NSString * ptime;   //上传时间
@property (nonatomic,assign) int replayCount;  //跟帖,播放次数
@property (nonatomic,strong) NSString *title;    //内容描述列表标题
@property (nonatomic,strong) NSString * tid;     //获取列表id
@property (nonatomic,strong) NSString * docid;
@property (nonatomic,strong) NSString * size;    //音频大小

@end
