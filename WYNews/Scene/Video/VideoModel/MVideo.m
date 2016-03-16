//
//  MVideo.m
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "MVideo.h"
#import "MTLValueTransformer.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation MVideo

- (NSString *)description {
    return [NSString stringWithFormat:@"title = %@ content = %@      titletop = %.2f title_h = %.2f content_h = %.2f video_h = %.2f bottonbar_h = %.2f cotent_h = %.2f cell_h =%.2f",_title,_content,_titleTop,_titleHeight,_contentHeight,_videoHeight,_bottomBarHeight,_containerHeight,_cellHeight];
}

- (instancetype)init
{
    if (self == [super init]) {
        self.statusLayout = [[VideoStatusLayout alloc]init];
        self.videoHeight = kPlayViewHeight;
        self.bottomBarHeight = kBottomToolbarHeight;
        self.marginBottom = kToolbarBottomMargin;
    }
    return self;
}

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"videoUrl":@"mp4_url",
             @"m3u8Url":@"m3u8_url",
             @"thumbImgUrl":@"cover",
             @"updateTime":@"ptime",
             @"addTime":@"add_time",
             @"content":@"description",
             @"video_id":@"vid",
             @"videoSource":@"videosource",
             @"reply_id":@"replyid"
             };
}

// 由于网易的布局比较简单，数据基本上都是标题描述格式，字符串的高度只是做局部动态调整（动态调整适合复杂布局）
- (void)layout {
    if (nil != self.title) {
        self.titleTop = kTitleViewTopMargin;
        self.titleHeight = kTopViewTitleHeight;
    }
    if (nil != self.content) {
        self.contentHeight = kTopViewContentHeight;
    }
    self.videoTop = _titleTop + _titleHeight + _contentHeight + kPlayViewTopInset;
    self.containerHeight = _videoTop + _videoHeight + _bottomBarHeight;
    self.cellHeight = _containerHeight + _marginBottom;
}

@end



@implementation MVideoList

- (instancetype)initWithVideoList:(NSMutableArray *)videoList
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.videoList = videoList;
    self.currentPage = 0;
    return self;
}

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"videoList":@"V9LG4B3A0"  // 网易给的数据
             };
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"videoList"]) {
        NSArray * videoList = value;
        for (MVideo * video in videoList) {
            [video layout];
        }
        _videoList = value;
    }else {
        [super setValue:value forKey:key];
    }
}

+ (NSValueTransformer *) videoListJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MVideo.class];
}

- (void)configMVideoListWithJsonDic:(NSDictionary *)jsonDic
{
    int currentPage = self.currentPage;
    MVideoList * videoList = nil;
    if (jsonDic[@"V9LG4B3A0"] && [jsonDic[@"V9LG4B3A0"] isKindOfClass:NSArray.class]) {
        videoList = [MTLJSONAdapter modelOfClass:MVideoList.class fromJSONDictionary:jsonDic error:nil];
    }
    if (currentPage == 0) {
        self.videoList = videoList.videoList;
    }else {
        [self.videoList addObjectsFromArray:videoList.videoList];
    }
    currentPage ++;
    self.currentPage = currentPage;
}


@end











