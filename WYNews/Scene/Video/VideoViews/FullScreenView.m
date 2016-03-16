/* Copyright (C) 2012 IGN Entertainment, Inc. */

#import "FullScreenView.h"
#import "PlaySliderView.h"
#import "Masonry.h"
#import "MVideo.h"
#import "NSString+Common.h"

//导航栏返回按钮图片宽度及文本图片间距
#define BACK_ICON_WH  18
#define ICON_TITLE_MARGIN 8

#define kDefaultBarHeight      64
#define kControlBarAutoFadeOutTimeinterval  3.0f


@interface BackButton : UIButton

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imgTextInsetSpacing;

@end

@implementation BackButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self setTintColor:[UIColor whiteColor]];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imgW = (_imageWidth == 0)?BACK_ICON_WH:_imageWidth;
    return CGRectMake(0, (CGRectGetHeight(contentRect) - imgW)/2, imgW, imgW);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat imgW = (_imageWidth == 0)?BACK_ICON_WH:_imageWidth;
    CGFloat space = (_imgTextInsetSpacing == 0)?ICON_TITLE_MARGIN:_imgTextInsetSpacing;
    return CGRectMake(imgW + space, 0,
                      CGRectGetWidth(contentRect) - (imgW + space),
                      CGRectGetHeight(contentRect));
}

@end




@interface ShrinkBackButton : UIButton

@end

@implementation ShrinkBackButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(8, 8, 12, CGRectGetHeight(contentRect) - 16);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(8 + 12 + 5, 8,
                      CGRectGetWidth(contentRect) - (12 + 3) - 16,
                      CGRectGetHeight(contentRect) - 16);
}

@end





@interface FullScreenView ()

@property (nonatomic, strong) UIView * topBar;
@property (nonatomic, strong) UIView * bottomBar;
@property (nonatomic, strong) PlaySliderView * sliderView;
@property (nonatomic, strong) UILabel * currentTimeLab;
@property (nonatomic, strong) UILabel * totalTimeLab;
@property (nonatomic, strong) BackButton * backBt;
@property (nonatomic, strong) ShrinkBackButton * shrinkScreenBt;
@property (nonatomic, assign) FullScrenViewType type;
@property (nonatomic, strong) MVideo * video;
@property (nonatomic, assign) BOOL isControlBarShowing;

@end

@implementation FullScreenView

- (id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    self.backgroundColor = [UIColor blackColor];
    [self setupViews];
    [self initAction];
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _type = FullScrenViewTypeNormal;
    [self setupViews];
    [self initAction];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame type:(FullScrenViewType)type
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _type = type;
    if (type == FullScrenViewTypeNormal) {
        [self setupViews];
        [self initAction];
    }
    
    return self;
}

- (void)setupViews
{
    CGFloat width = MAX(kScreenHeight, kScreenWidth);
    CGFloat height = MIN(kScreenWidth, kScreenHeight);
    // top bar
    self.topBar = [[UIView alloc]initWithFrame:CGRectMake(0, -kDefaultBarHeight, width, kDefaultBarHeight)];
    [self addSubview:_topBar];
    
    /* 渐变色 */
    //初始化渐变层
    CAGradientLayer * t_gradientLayer = [CAGradientLayer layer];
    t_gradientLayer.frame = _topBar.bounds;
    [_topBar.layer addSublayer:t_gradientLayer];
    
    //设置渐变颜色方向
    t_gradientLayer.startPoint = CGPointMake(0, 0);
    t_gradientLayer.endPoint = CGPointMake(0, 1);
    
    //设定颜色组
    t_gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.9].CGColor,
                               (__bridge id)[UIColor clearColor].CGColor];
    
    //设定颜色分割点
//    t_gradientLayer.locations = @[@(0.5f) ,@(1.0f)];
    
    // back bt
    self.backBt = [BackButton buttonWithType:UIButtonTypeCustom];
    [_backBt setImage:[[UIImage imageNamed:@"back"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_backBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBt setTitle:@"返回" forState:UIControlStateNormal];
    _backBt.titleLabel.font = [UIFont systemFontOfSize:15];
    _backBt.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_topBar addSubview:_backBt];
    
    
    // bottom bar
    self.bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, kDefaultBarHeight)];
    [self addSubview:_bottomBar];
    
    CAGradientLayer * b_gradientLayer = [CAGradientLayer layer];
    b_gradientLayer.frame = _topBar.bounds;
    [_bottomBar.layer addSublayer:b_gradientLayer];
    
    b_gradientLayer.startPoint = CGPointMake(0, 0);
    b_gradientLayer.endPoint = CGPointMake(0, 1);
    
    b_gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                               (__bridge id)[UIColor colorWithWhite:0 alpha:0.9].CGColor]
                               ;
    
    // current time lab
    self.currentTimeLab = [[UILabel alloc]init];
    _currentTimeLab.font = [UIFont systemFontOfSize:14];
    _currentTimeLab.textColor = [UIColor whiteColor];
    _currentTimeLab.textAlignment = NSTextAlignmentLeft;
    [_bottomBar addSubview:_currentTimeLab];
    
    // total time
    self.totalTimeLab = [[UILabel alloc]init];
    _totalTimeLab.font = [UIFont systemFontOfSize:14];
    _totalTimeLab.textColor = [UIColor whiteColor];
    _totalTimeLab.textAlignment = NSTextAlignmentLeft;
    [_bottomBar addSubview:_totalTimeLab];
    
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
    [_bottomBar addSubview:_sliderView];
    
    // shrink
    self.shrinkScreenBt = [ShrinkBackButton buttonWithType:UIButtonTypeCustom];
    [_shrinkScreenBt setBackgroundImage:[UIImage imageNamed:@"video_btn_fullscreen_b"] forState:UIControlStateNormal];
    [_bottomBar addSubview:_shrinkScreenBt];
    
    
    
    // layout subviews
    [_backBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(_topBar).offset(5);
        make.height.mas_equalTo(36);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [_currentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kPaddingLeftWidth);
        make.height.mas_equalTo(15);
        make.bottom.mas_equalTo(_bottomBar).offset(-(28 - 15/2));
        make.width.mas_equalTo(40);
    }];
    
    [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_currentTimeLab.mas_right).offset(5);
        make.height.mas_equalTo(40);
        make.centerY.mas_equalTo(_currentTimeLab);
    }];
    
    [_totalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_sliderView.mas_right).offset(5);
        make.height.mas_equalTo(_currentTimeLab);
        make.width.mas_equalTo(_currentTimeLab);
        make.centerY.mas_equalTo(_currentTimeLab);
    }];
    
    [_shrinkScreenBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_totalTimeLab.mas_right).offset(10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(_shrinkScreenBt.mas_height);
        make.centerY.mas_equalTo(_totalTimeLab);
        make.right.mas_equalTo(-kPaddingLeftWidth);
    }];
}

- (void)initAction
{
    @weakify(self)
    [_sliderView addTouchBeganAction:^(PlaySliderView *slider) {
        @strongify(self)
        [self cancelAutoFadeOutControlBar];
    }];
    [_sliderView addTouchEndAction:^(PlaySliderView *slider) {
        @strongify(self)
        if (self.changeProgressAction) {
            self.changeProgressAction(slider);
        }
        [self autoFadeOutControlBar];
    }];
    
    [_backBt addAction:^(id sender) {
        @strongify(self)
        if (self.shrinkScreenAction) {
            self.shrinkScreenAction(sender);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [_shrinkScreenBt addAction:^(id sender) {
        @strongify(self)
        if (self.shrinkScreenAction) {
            self.shrinkScreenAction(sender);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    // gestur
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHidenControlBar)];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playPauseAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
}

- (void)showOrHidenControlBar
{
    if (self.video.statusLayout.playStatus == VideoPlayStatusPlaying || self.video.statusLayout.playStatus == VideoPlayStatusPause) {
        if (_isControlBarShowing) {
            [self animateHideControlBar];
        }else {
            [self animateShowControlBar];
        }
    }
}

- (void)playPauseAction:(UITapGestureRecognizer *)ges
{
    if (self.playPauseAction) {
        _playPauseAction(self);
    }
}

- (void)animateShowControlBar
{
    if (_isControlBarShowing) {
        return;
    }
    CGFloat height = MIN(kScreenWidth, kScreenHeight);
    [UIView animateWithDuration:kShowControllViewAnimatedDuration animations:^{
        _topBar.y = 0;
        _bottomBar.y = height - kDefaultBarHeight;
    } completion:^(BOOL finished) {
        _isControlBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
    
    if (self.controlBarAction) {
        _controlBarAction(!_isControlBarShowing);
    }
}

- (void)animateHideControlBar
{
    if (!_isControlBarShowing) {
        return;
    }
    CGFloat height = MIN(kScreenWidth, kScreenHeight);
    [UIView animateWithDuration:kShowControllViewAnimatedDuration animations:^{
        _topBar.y = -kDefaultBarHeight;
        _bottomBar.y = height;
    } completion:^(BOOL finished) {
        _isControlBarShowing = NO;
    }];
    
    if (self.controlBarAction) {
        _controlBarAction(!_isControlBarShowing);
    }
}

- (void)autoFadeOutControlBar
{
    if (!self.isControlBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHideControlBar) object:nil];
    [self performSelector:@selector(animateHideControlBar) withObject:nil afterDelay:kControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHideControlBar) object:nil];
}

- (BOOL)isSLiderDragging
{
    return _sliderView.isDragging;
}

- (void)refreshControlBar:(MVideo *)video
{
    self.video = video;
    NSString * title = video.content;
    [_backBt setTitle:title forState:UIControlStateNormal];
    
    // time
    _currentTimeLab.text = [NSDate formattedPlayTimeFromTimeInterval:video.statusLayout.currentTime];
    _totalTimeLab.text = [NSDate formattedPlayTimeFromTimeInterval:video.statusLayout.totalTime];
    
    // time ui
    if (video.statusLayout.totalTime >= 60 *60) {
        [_currentTimeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40 + 22);
        }];
    }else {
        [_currentTimeLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
        }];
    }
}

- (void)refreshProgress:(VideoStatusLayout *)videoStatus
{
    _currentTimeLab.text = [NSDate formattedPlayTimeFromTimeInterval:videoStatus.currentTime];
    [_sliderView setValue:videoStatus.progress animated:YES];
    [_sliderView setProgress:videoStatus.buffer animated:YES];
}



@end
