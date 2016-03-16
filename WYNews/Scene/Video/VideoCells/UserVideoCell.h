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