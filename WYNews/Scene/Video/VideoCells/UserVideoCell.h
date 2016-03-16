//
//  UserVideoCell.h
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayView.h"
#import "MVideo.h"

/*!
 *  @视频的主要布局有数据源MVideo的layout后计算所得frame数据，布局的动态性也由数据源决定
 *  @视频cell的播放状态，是根据数据源中 statusLayout 的不同状态做不同的更新。当改变数据源中 statusLayout 的状态值并作刷新即可改变视频cell的状态
 */


UIKIT_EXTERN NSString *const kUserVideoCellIdfy_Normal;
UIKIT_EXTERN NSString *const kUserVideoCellIdfy_OtherStyle;

typedef NS_ENUM(NSInteger, UserVideoType) {
    UserVideoTypeNormal,
    UserVideoTypeForward
};

@class UserVideoBottomBar;
@class UserVideoTitleView;
@class UserVideoCell;

@protocol UserVideoCellDelegate <NSObject>

- (void)userVideoCell:(UserVideoCell *)cell startPlay:(MVideo *)video;

- (void)userVideoCell:(UserVideoCell *)cell playPuse:(MVideo *)video;

- (void)userVideoCell:(UserVideoCell *)cell fullScreenBt:(UIButton *)fullScreenBt;

- (void)userVideoCell:(UserVideoCell *)cell changePlayProgress:(CGFloat)percentTime;

- (void)userVideoCell:(UserVideoCell *)cell toolBarClickedAtIndex:(NSInteger)index;

@end

@interface UserVideoCell : UITableViewCell

@property (nonatomic, strong) UserVideoTitleView * titleView;
@property (nonatomic, strong) VideoPlayView * playView;
@property (nonatomic, strong) UserVideoBottomBar * bottomBar;
@property (nonatomic, assign) id<UserVideoCellDelegate>delegate;

- (void)configCellWith:(MVideo *)video;

- (void)refreshPlayViewBy:(MVideo *)video isOnlyProgress:(BOOL)isProgress;

+ (CGFloat)cellHeightWith:(MVideo *)video;

@end


@interface UserVideoBottomBar : UIView
@end

@interface UserVideoTitleView : UIView
@end