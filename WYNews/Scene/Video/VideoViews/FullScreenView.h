/* Copyright (C) 2012 IGN Entertainment, Inc. */

#import <UIKit/UIKit.h>
#import "AVPlayerManger.h"

#define kShowControllViewAnimatedDuration  0.3f

typedef NS_ENUM(NSInteger, FullScrenViewType) {
    FullScrenViewTypeNormal,
    FullScrenViewTypeTransition
};
@interface FullScreenView : UIView<AVPlayerViewDelegate>

@property (nonatomic, weak) AVPlayerManger * playerManger;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL isSLiderDragging;

@property (nonatomic, copy) void(^changeProgressAction)(UISlider * slider);
@property (nonatomic, copy) void(^shrinkScreenAction)(UIButton * button);
@property (nonatomic, copy) void(^controlBarAction)(BOOL isShow);
@property (nonatomic, copy) void(^playPauseAction)(id sender);

- (instancetype)initWithFrame:(CGRect)frame type:(FullScrenViewType)type;

- (void)setPlayer:(AVPlayer *)player;

- (void)refreshControlBar:(id)model;

- (void)refreshProgress:(id)videoStatus;

@end
