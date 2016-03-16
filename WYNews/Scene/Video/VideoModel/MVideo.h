//
//  MVideo.h
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "Mantle.h"
#import "VideoStatusLayout.h"

// 这里应该给尺寸做适配
#define kVideoLeftPadding       10.0
#define kTitleViewTopMargin     6      // 标题顶部留白
#define kTopViewTitleHeight     40     // 标题
#define kTopViewContentHeight   20     // 描述
#define kPlayViewTopInset       8
#define kPlayViewHeight         (kScreenWidth - 2 *kVideoLeftPadding) * 9/16
#define kBottomToolbarHeight    55     // cell 下方工具栏高度
#define kToolbarBottomMargin    7      // cell 下方灰色留白

@interface MVideo : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString * title;       //标题，描述
@property (nonatomic, strong) NSString * content;     //内容
@property (nonatomic, strong) NSString * thumbImgUrl; //封面图片URL
@property (nonatomic, strong) NSString * videoUrl;    //MP4视频URL
@property (nonatomic, strong) NSString * m3u8Url;     //m3u8视频URL
@property (nonatomic, strong) NSString * updateTime;  //更新时间
@property (nonatomic, strong) NSString * videoSource; //更新时间
@property (nonatomic, strong) NSString * replyid;
@property (nonatomic, strong) NSString * video_id;
@property (nonatomic, strong) NSString * reply_id;     //跟帖id
@property (nonatomic, assign) NSInteger replyCount;   //跟帖人数
@property (nonatomic, assign) NSInteger playCount;    //播放次数
@property (nonatomic, assign) NSInteger length;       //时长
// layout size
@property (nonatomic, assign) CGFloat titleTop;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat videoTop;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, assign) CGFloat bottomBarHeight;
@property (nonatomic, assign) CGFloat marginBottom;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat containerHeight;
// video status layout
@property (nonatomic, strong) VideoStatusLayout * statusLayout;

- (void)layout; // 计算布局

@end


@interface MVideoList : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSMutableArray * videoList;
@property (nonatomic, assign) int currentPage;

- (instancetype)initWithVideoList:(NSMutableArray *)videoList;

- (void)configMVideoListWithJsonDic:(NSDictionary *)jsonDic;

@end
