//
//  HeadLineModel.h
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NSCoding.h"

@interface NewsModel : NSObject<NSCoding>

//头条新闻内容第一个model的自由属性
@property (nonatomic,assign) BOOL hasHead;             //是否存在表头图片，即作为轮播图的第一张
@property (nonatomic,strong) NSString * photosetID;    //如果hasHead是1，则这个ID是进入详情图片的ID
//头条所由新闻内容的共同属性
@property (nonatomic,assign) NSInteger replyCount;     //跟帖人数
@property (nonatomic,strong) NSString * title;         //标题
@property (nonatomic,strong) NSString * digest;        //内容描述
@property (nonatomic,strong) NSString * docid;         //点击进入详情的URL的ID
@property (nonatomic,strong) NSString * imgsrc;        //图片URL
@property (nonatomic,strong) NSString * skipType;      //如果value值是“photoset”，则表示显示的图片平铺列表,如果是“special”表示是“专题”，跟帖的lable替换成“专题”。
@property (nonatomic,strong) NSString * ptime;         //更新时间
@property (nonatomic,strong) NSString * source;        //新闻来源
@property (nonatomic,strong) NSString * TAG;           //value值是“视频”，“独家”.....
//当格式是photoset时，将图片放入数组
@property (nonatomic,strong) NSMutableArray * imgArray;

@end
