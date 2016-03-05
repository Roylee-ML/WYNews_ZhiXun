//
//  FMListModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMListModel : NSObject<NSCoding>

@property (nonatomic,strong) NSString * source;  //音乐来源
@property (nonatomic,strong) NSString * title;   //音乐列表标题
@property (nonatomic,strong) NSString * imgsrc;  //图片网址
@property (nonatomic,strong) NSString * docid;   //获取播放音乐的id
@property (nonatomic,strong) NSString * ptime;   //音乐上传时间
@property (nonatomic,strong) NSString * size;    //音频大小

@end
