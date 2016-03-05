//
//  NewsDetailModel.h
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDetailModel : NSObject<NSCoding>
@property(nonatomic,strong)NSString * title;//详情标题
@property(nonatomic,strong)NSString * source;//来源(网易娱乐专稿)
@property(nonatomic,assign)NSInteger ptime;//时间(2015-05-29 14:41:16)按(05-29 14:41)格式显示
@property(nonatomic,strong)NSString * digest;//描述(5月29日上午，范冰冰晒出与李晨甜蜜合影，并配文：“我们”，大方承认与李晨正在热恋中。恋情公布后，李晨旧爱张馨予在微博发文称最后一次发与李晨有关的微博，感慨曾一直以为李晨会一直陪在身边，不过尽管如此，依旧祝福昔日男友要幸福。)
@property(nonatomic,strong)NSMutableArray *img;//图片相关的数组
@property(nonatomic,strong)NSMutableArray * video;//视频相关的数组
@property(nonatomic,strong)NSString * ref;//判断是图片(<!--IMG#0-->)还是视频(<!--VIDEO#0--></p><p>)
@property(nonatomic,strong)NSString * alt;//图片或者视频下方的标题
@property(nonatomic,strong)NSString * src;//图片的网址(可能是图集)
@property(nonatomic,strong)NSString * url_mp4;//视频网址
@property(nonatomic,strong)NSString * body;//正文(图片/视频+文字)
@property(nonatomic,strong)NSString * replyCount;//跟帖数
@property(nonatomic,strong)NSString * attributedText;//属性文字
@property(nonatomic,strong)NSMutableArray * relative_sys;//相关新闻
@property(nonatomic,strong)NSString * spcontent; //延伸.回顾

@end
