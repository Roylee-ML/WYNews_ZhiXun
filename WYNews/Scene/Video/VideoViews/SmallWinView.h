//
//  SmallWinView.h
//  WYNews
//
//  Created by Roy lee on 16/3/17.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerManger.h"

@interface SmallWinView : UIView<AVPlayerViewDelegate>

@property (nonatomic, weak) AVPlayerManger * playerManger;
@property (nonatomic, copy) void(^tapAction)(SmallWinView * view);
@property (nonatomic, copy) void(^closeAction)(SmallWinView * view);

- (void)setPlayer:(AVPlayer *)player;

@end
