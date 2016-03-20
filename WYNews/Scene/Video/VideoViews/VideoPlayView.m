//
//  VideoPlayView.m
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "VideoPlayView.h"
#import "PlaySliderView.h"
#import "UIImage+ImageWithColor.h"
#import "MVideo.h"
#import "VideoStatusLayout.h"
#import "UIImageView+WebCache.h"
#import "AnnularLoader.h"

#define kLineProgressHeight     2.5f
#define kLogoImageWidth         kScreenWidth *1.2/5

static const CGFloat kVideoControlBarHeight = 40.0;
static const CGFloat kVideoControlAnimationTimeinterval = 0.3;
static const CGFloat kVideoControlBarAutoFadeOutTimeinterval = 3.0;


@interface VideoCoverImageView ()

@property (nonatomic, strong) UIImageView * logoImageV;
@property (nonatomic, strong) AnnularLoader * loader;

@end

@implementation VideoCoverImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIImage * image = [[UIImage imageNamed:@"video_content_logo"] imageWithColor:[UIColor colorWithHex:@"c2c2c2"]];
    self.logoImageV = [[UIImageView alloc]initWithImage:image];
    CGSize imageSize = image.size;
    [self addSubview:_logoImageV];
    [_logoImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kLogoImageWidth, imageSize.height/imageSize.width * kLogoImageWidth));
    }];
}

- (void)startLoader {
    if (!_loader) {
        self.loader = [AnnularLoader new];
        _loader.boundsWidth = 20;
        _loader.offset = CGPointMake((_logoImageV.left - 22) - self.width/2, 0);
        _loader.colorArray = @[[UIColor colorWithHex:@"6e6e6e"]];
        _loader.lineWidth = 1.0f;
        [self addSubview:_loader];
    }
    self.image = [UIImage imageNamed:@"video_content_bg"];
    _logoImageV.hidden = NO;
    [_loader startAnimation];
}

- (void)stopLoader
{
    _logoImageV.hidden = YES;
    if (_loader) {
        [self.loader stopAnimation];
        [_loader removeFromSuperview];
        self.loader = nil;
    }
}

- (void)updateLoaderByStatus:(MVideo *)video
{
    VideoPlayStatus playStatus = video.statusLayout.playStatus;
    if (playStatus == VideoPlayStatusBeginPlay) {
        [self startLoader];
        self.hidden = NO;
    }else {
        BOOL hiden = (playStatus == VideoPlayStatusPlaying || playStatus == VideoPlayStatusPause);
        [self stopLoader];
        self.hidden = hiden;
    }
}


@end







@interface VideoPlayView ()

@property (nonatomic, strong) UIView * controlView;
@property (nonatomic, strong) PlaySliderView * sliderView;
@property (nonatomic, strong) UIView * lineProgressV;
@property (nonatomic, strong) UILabel * currentTimeLab;
@property (nonatomic, strong) UILabel * totalTimeLab;
@property (nonatomic, strong) UIButton * fullScreenBt;
@property (nonatomic, strong) UIButton * playBt;
@property (nonatomic, assign) BOOL isControlBarShowing;
@property (nonatomic, strong) VideoStatusLayout * videoStatus;


@end

@implementation VideoPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    [self setupViews];
    [self initAction];
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_lineProgressV.height == 0) {   // 确保执行一次
        _lineProgressV.frame = CGRectMake(0, self.height - kLineProgressHeight, 0, kLineProgressHeight);
    }
    _lineProgressV.bottom = self.height;
}

- (void)setupViews
{
    self.clipsToBounds = YES;
    // video bg
    self.videoCoverImgV = [[VideoCoverImageView alloc]init];
    _videoCoverImgV.backgroundColor = [UIColor whiteColor];
    _videoCoverImgV.contentMode = UIViewContentModeScaleAspectFill;
    _videoCoverImgV.clipsToBounds = YES;
    [self addSubview:_videoCoverImgV];
    
    // slider
    [self configSliderBgView];
    
    // bottom line progress
    self.lineProgressV = [[UIView alloc]init];
    _lineProgressV.backgroundColor = [UIColor colorWithHex:@"cd0000"];
    _lineProgressV.hidden = YES;
    [self addSubview:_lineProgressV];
    
    // play button
    self.playBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBt setBackgroundImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
    [self addSubview:_playBt];
    
    // layout
    [_videoCoverImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    CGFloat playBtWidth = 50;
    [_playBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.height.mas_equalTo(@[@(playBtWidth),_playBt.mas_width]);
    }];
}

- (void)configSliderBgView
{
    // bg
    self.controlView = [[UIView alloc]init];
    _controlView.alpha = 0;
    [self addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(kVideoControlBarHeight);
    }];
    
    // 渐变色
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, kScreenWidth, kVideoControlBarHeight);
    [_controlView.layer addSublayer:gradientLayer];
    
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0 alpha:0.9].CGColor]
    ;
    
    // current time lab
    self.currentTimeLab = [[UILabel alloc]init];
    _currentTimeLab.font = [UIFont systemFontOfSize:13];
    _currentTimeLab.textColor = [UIColor whiteColor];
    _currentTimeLab.textAlignment = NSTextAlignmentLeft;
    [_controlView addSubview:_currentTimeLab];
    
    // total time
    self.totalTimeLab = [[UILabel alloc]init];
    _totalTimeLab.font = [UIFont systemFontOfSize:13];
    _totalTimeLab.textColor = [UIColor whiteColor];
    _totalTimeLab.textAlignment = NSTextAlignmentLeft;
    [_controlView addSubview:_totalTimeLab];
    
    // slider
    self.sliderView = [[PlaySliderView alloc]init];
    _sliderView.minimumValue = 0;
    _sliderView.maximumValue = 1;
    _sliderView.value = 0.0;
    _sliderView.minimumTrackTintColor = [UIColor whiteColor];
    _sliderView.maximumTrackTintColor = [UIColor clearColor];
    
    UIImage * n_image = [UIImage imageNamed:@"player_thumb"];
    [_sliderView setThumbImage:n_image forState:UIControlStateNormal];
    [_sliderView setThumbImage:n_image forState:UIControlStateHighlighted];
    [_controlView addSubview:_sliderView];
    
    NSLog(@"%@",_sliderView);
    
    // full screen button
    self.fullScreenBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenBt setBackgroundImage:[UIImage imageNamed:@"video_btn_fullscreen"] forState:UIControlStateNormal];
    [_controlView addSubview:_fullScreenBt];
    
    [_currentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(_controlView);
        make.width.mas_equalTo(37);
    }];
    
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_currentTimeLab.mas_right).offset(3);
        make.height.mas_equalTo(_controlView.mas_height);
        make.centerY.mas_equalTo(_currentTimeLab);
    }];
    
    [_totalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_sliderView.mas_right).offset(3);
        make.height.mas_equalTo(_currentTimeLab);
        make.width.mas_equalTo(_currentTimeLab);
        make.centerY.mas_equalTo(_currentTimeLab);
    }];
    
    [_fullScreenBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_totalTimeLab.mas_right).offset(10);
        make.height.mas_equalTo(@[@(18),_fullScreenBt.mas_width]);
        make.centerY.mas_equalTo(_totalTimeLab);
        make.right.mas_equalTo(-kPaddingLeftWidth);
    }];
}

- (void)initAction
{
    // single tap: show or hiden slider and  control play pause
    @weakify(self)
    UIGestureRecognizer * tap = [self addGestureRecognizer:UITapGestureRecognizer.class action:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self showOrHidenVideoControlView];
    }];
    
    // double click
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playPauseAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    
    // play
    [_playBt addAction:^(id sender) {
        NSLog(@"点击了播放视频.......");
        @strongify(self)
        if (self.playVideoAction) {
            self.playVideoAction(self.playBt);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    // fullscreen
    [_fullScreenBt addAction:^(id sender) {
        NSLog(@"点击了全屏播放........");
        @strongify(self)
        [self animateHideControlView];
        if (self.fullScreenAction) {
            self.fullScreenAction(self.fullScreenBt);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    // slider
    [_sliderView addTouchBeganAction:^(PlaySliderView *slider) {
        @strongify(self)
        [self cancelAutoFadeOutControlBar];
    }];
    [_sliderView addTouchValueChangedAction:^(PlaySliderView *slider) {
        @strongify(self)
        [self autoFadeOutControlBar];
        if (self.changeProgressAction) {
            self.changeProgressAction(slider);
        }
    }];
}

- (void)playPauseAction:(UITapGestureRecognizer *)ges
{
    if (self.playPauseAction) {
        _playPauseAction(_videoCoverImgV);
    }
}

- (void)configPlayViewBy:(MVideo *)video
{
    if (nil == video) {
        return;
    }
    [_videoCoverImgV sd_setImageWithURL:[NSURL URLWithString:video.thumbImgUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _controlView.alpha = 0;
    _isControlBarShowing = NO;
    [self refreshPlayViewByStatus:video];
}

- (void)refreshPlayViewByStatus:(MVideo *)video
{
    self.videoStatus = video.statusLayout;
    // play hud and start bt
    switch (_videoStatus.playStatus) {
        case VideoPlayStatusNormal:
            self.playBt.hidden = NO;
            self.lineProgressV.hidden = YES;
            break;
        case VideoPlayStatusBeginPlay:
            self.playBt.hidden = YES;
            self.lineProgressV.hidden = YES;
            self.lineProgressV.width = 0;
            break;
        case VideoPlayStatusPlaying:
            self.playBt.hidden = YES;
            self.lineProgressV.hidden = NO;
            break;
        case VideoPlayStatusPause:
            self.playBt.hidden = NO;
            self.lineProgressV.hidden = YES;
            break;
        case VideoPlayStatusEndPlay:
            self.playBt.hidden = NO;
            self.lineProgressV.hidden = YES;
            break;
        case VideoPlayStatusFailedPlay:
            self.playBt.hidden = NO;
            self.lineProgressV.hidden = YES;
            break;
            
        default:
            break;
    }
    // loader
    [_videoCoverImgV updateLoaderByStatus:video];
    // update time ui
    if (_videoStatus.totalTime >= 60 * 60) {
        [_currentTimeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(37 + 20);
        }];
    }else {
        [_currentTimeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(37);
        }];
    }
    _totalTimeLab.text = [NSDate formattedPlayTimeFromTimeInterval:_videoStatus.totalTime];
    [self refreshProgress:_videoStatus];
}

- (void)refreshProgress:(VideoStatusLayout *)videoStatus
{
    // sider
    _currentTimeLab.text = [NSDate formattedPlayTimeFromTimeInterval:videoStatus.currentTime];
    
    BOOL s_animated = videoStatus.progress > _sliderView.value?YES:NO;
    BOOL p_animated = videoStatus.buffer > _sliderView.progress?YES:NO;
    [_sliderView setValue:videoStatus.progress animated:s_animated];
    [_sliderView setProgress:videoStatus.buffer animated:p_animated];
    
    // line progress
    if (videoStatus.playStatus == VideoPlayStatusPlaying) {
        [UIView animateWithDuration:1.0f animations:^{
            _lineProgressV.width = self.width*videoStatus.progress;
        }];
    }
}

- (BOOL)isSliderDragging
{
    return _sliderView.isDragging;
}

- (void)autoFadeOutControlBar
{
    if (!self.isControlBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHideControlView) object:nil];
    [self performSelector:@selector(animateHideControlView) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHideControlView) object:nil];
}

- (void)showOrHidenVideoControlView
{
    if (self.videoStatus.playStatus == VideoPlayStatusPlaying || self.videoStatus.playStatus == VideoPlayStatusPause) {
        if (_isControlBarShowing){
            [self animateHideControlView];
        }else {
            [self animateShowControlView];
        }
    }
}

- (void)animateShowControlView
{
    if (self.isControlBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.controlView.alpha = 1.0;
        self.lineProgressV.alpha = 0;
    } completion:^(BOOL finished) {
        self.isControlBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)animateHideControlView
{
    if (!_isControlBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        _controlView.alpha = 0;
        _lineProgressV.alpha = 1;
    } completion:^(BOOL finished) {
        _isControlBarShowing = NO;
    }];
}


@end
