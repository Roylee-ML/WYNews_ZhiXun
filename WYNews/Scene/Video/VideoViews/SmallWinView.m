//
//  SmallWinView.m
//  WYNews
//
//  Created by Roy lee on 16/3/17.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "SmallWinView.h"

@interface SmallWinView ()

@property (nonatomic, strong) UIButton * closeBt;

@end

@implementation SmallWinView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setupViews {
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    self.layer.masksToBounds = YES;
    
    self.closeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBt setBackgroundImage:[UIImage imageNamed:@"video_player_exit"] forState:UIControlStateNormal];
    [self addSubview:_closeBt];
    [_closeBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(4);
        make.left.mas_equalTo(4);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    // close action
    @weakify(self);
    [_closeBt addAction:^(id sender) {
        @strongify(self);
        if (self.closeAction) {
            self.closeAction(self);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    // tap action
    [self addGestureRecognizer:UITapGestureRecognizer.class action:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        if (self.tapAction) {
            self.tapAction(self);
        }
    }];
}

@end
