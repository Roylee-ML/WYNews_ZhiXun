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

- (instancetype)init
{
    if (self == [super init]) {
        self.statusLayout = [[VideoStatusLayout alloc]init];
        self.videoHeight = kPlayViewHeight;
        self.bottomBarHeight = kBottomToolbarHeight;
        self.marginTop = kVideoCellTopMargin;
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
    self.cellHeight = _marginTop + _containerHeight;
}

@end




@implementation MVideoSort

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"sort_id":@"sid",
             @"imageUrl":@"imgsrc"
             };
}

@end



@implementation MHomeVideoList

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
             @"homeSort_id":@"videoHomeSid",
             @"videoSortList":@"videoSidList",
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

+ (NSValueTransformer *) videoSortListJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MVideoSort.class];
}

+ (NSValueTransformer *) videoListJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MVideo.class];
}

- (void)configMHomeVideoListWithJsonDic:(NSDictionary *)jsonDic
{
    int currentPage = self.currentPage;
    MHomeVideoList * videoList = nil;
    if (jsonDic[@"videoList"] && [jsonDic[@"videoList"] isKindOfClass:NSArray.class]) {
        videoList = [MTLJSONAdapter modelOfClass:MHomeVideoList.class fromJSONDictionary:jsonDic error:nil];
    }
    if (currentPage == 0) {
        self.videoList = videoList.videoList;
    }else {
        [self.videoList addObjectsFromArray:videoList.videoList];
    }
    currentPage ++;
    self.currentPage = currentPage;
    // sort list
    self.videoSortList = videoList.videoSortList;
    self.homeSort_id = videoList.homeSort_id;
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
    NSString * videoSid = [ShareManger defoutManger].currentVideoSid;
    return @{
             @"videoList":videoSid,
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
    NSString * sort_id = [ShareManger defoutManger].currentVideoSid;
    if (jsonDic[sort_id] && [jsonDic[sort_id] isKindOfClass:NSArray.class]) {
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















