//
//  VideoPlayView.h
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITapImageView.h"
#import "AVPlayerManger.h"

@interface VideoPlayView : UIView<AVPlayerViewDelegate>

@property (nonatomic, weak) AVPlayerManger * playerManger;
@property (nonatomic, strong) UITapImageView * videoBgImgV;
@property (nonatomic, copy) void(^fullScreenAction)(UIButton * bt);
@property (nonatomic, copy) void(^playVideoAction)(UIButton * bt);
@property (nonatomic, copy) void(^playPauseAction)(UITapImageView * imgView);
@property (nonatomic, copy) void(^changeProgressAction)(UISlider * slider);

- (void)setPlayer:(AVPlayer *)player;

- (void)refreshPlayViewByStatus:(id)video;

- (void)refreshProgress:(id)videoStatus;

- (void)configPlayViewBy:(id)video;

- (BOOL)isSliderDragging;

@end
