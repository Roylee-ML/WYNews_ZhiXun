/* Copyright (C) 2012 IGN Entertainment, Inc. */

#import "FullScreenViewController.h"
#import "MVideo.h"

#define kNotificationFinshedTranslateAnimation  @"finished_translate_animation"
#define kFullScreenTransitionTime               0.3f

@interface FullScreenViewController ()<AVPlayerDelegate>

@property (nonatomic, strong) AVPlayerManger * playerManger;
@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic, strong) MVideo * video;

@end

@implementation FullScreenViewController

- (void)dealloc
{
    self.playerManger = nil;
}

- (id)init
{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (instancetype)initWithAVPlayerManger:(AVPlayerManger *)playerManger video:(MVideo *)video
{
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.playerManger = playerManger;
    self.playerManger.delegate  = self;
    self.video = video;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initView];
    if (self.video.statusLayout.playStatus == VideoPlayStatusPause) {
        [self.playerManger playContent];
        self.video.statusLayout.playStatus = VideoPlayStatusPlaying;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showOrHidenStatusBar:NO];
}

- (void)initView
{
    CGFloat height = kScreenWidth;
    CGFloat width = kScreenHeight;
    self.fullScreenView = [[FullScreenView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:self.fullScreenView];
    [_fullScreenView refreshControlBar:_video];
    
    // action
    @weakify(self)
    [_fullScreenView setPlayPauseAction:^(id sender) {
        @strongify(self)
        if (self.video.statusLayout.playStatus == VideoPlayStatusPlaying) {
            self.video.statusLayout.playStatus = VideoPlayStatusPause;
            [self.playerManger pauseContent];
        }else if (self.video.statusLayout.playStatus == VideoPlayStatusPause) {
            self.video.statusLayout.playStatus = VideoPlayStatusPlaying;
            [self.playerManger playContent];
        }
    }];
    [_fullScreenView setShrinkScreenAction:^(UIButton * bt) {
        @strongify(self)
        if (self.video.statusLayout.playStatus == VideoPlayStatusPause) {
            [self.playerManger playContent];
            self.video.statusLayout.playStatus = VideoPlayStatusPlaying;
        }
        [self dismissFullScreenCompletion:^{
            if (self.dismissBlock) {
                self.dismissBlock(NO);
            }
        }];
    }];
    [_fullScreenView setChangeProgressAction:^(UISlider * slider) {
        @strongify(self)
        CGFloat value = slider.value;
        self.video.statusLayout.progress = value;
        NSTimeInterval time = value * [self.playerManger.player currentItemDuration];
        [self.playerManger seekToTimeInSecond:time completionHandler:^(BOOL finished) {
            
        }];
    }];
    [_fullScreenView setControlBarAction:^(BOOL isControlBarShowing) {
        @strongify(self)
        [self showOrHidenStatusBar:isControlBarShowing];
    }];
}

- (void)showOrHidenStatusBar:(BOOL)isShow
{
    _showStatusBar = isShow;
    // 状态栏的隐藏在一个动画的block中调用setNeedsStatusBarAppearanceUpdate，系统会将状态栏的改变添加到动画的block中
    [UIView animateWithDuration:kShowControllViewAnimatedDuration animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark - AVPlayerDelegate

- (void)videoPlayer:(AVPlayerManger *)playerManger didCurrentBuffer:(double)currentBf totalBuffer:(double)totalBf
{
    CGFloat buffer = currentBf/totalBf;
    self.video.statusLayout.buffer = buffer;
    [_fullScreenView refreshProgress:self.video.statusLayout];
}

- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayFrame:(id<AVPlayerTrackProtocol>)track time:(NSTimeInterval)time lastTime:(NSTimeInterval)lastTime
{
    if (_fullScreenView.isSLiderDragging) {
        return;
    }
    
    CGFloat percent = time/[self.playerManger.player currentItemDuration];
    self.video.statusLayout.progress = percent;
    self.video.statusLayout.currentTime = time;
    
    [_fullScreenView refreshProgress:_video.statusLayout];
}

- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayToEnd:(id<AVPlayerTrackProtocol>)track
{
    [self dismissFullScreenCompletion:^{
        if (self.dismissBlock) {
            self.dismissBlock(YES);
        }
    }];
}

- (void)handleErrorCode:(AVPlayerErrorCode)errorCode track:(id<AVPlayerTrackProtocol>)track customMessage:(NSString*)customMessage
{
    
}

#pragma mark - DisMissFullScreen

- (void)dismissFullScreenCompletion:(void (^)(void))completion
{
    CGFloat width = kScreenHeight;
    CGFloat height = kScreenWidth;
    UIView * transitionMaskV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, height, width)];
    FullScreenView * transitionView = [[FullScreenView alloc]initWithFrame:CGRectMake(-(width - height)/2, (width - height)/2, width, height) type:FullScrenViewTypeTransition];
    [transitionMaskV addSubview:transitionView];
    [[UIApplication sharedApplication].keyWindow addSubview:transitionMaskV];
    
    transitionMaskV.backgroundColor = [UIColor blackColor];
    transitionView.backgroundColor = [UIColor blackColor];
    transitionView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    // player trans
    [self.playerManger setCurrentPlayerView:transitionView];
    
    NSAssert(nil != _dismissFromViewBlock, @"dismissFromViewBlock must not be nil!you must return a fromView as a datasource view for transition");
    UIView<AVPlayerViewDelegate> * fromView = self.dismissFromViewBlock();
    
    [self dismissViewControllerAnimated:NO completion:^{
        CGRect frame = [transitionMaskV convertRect:fromView.frame fromView:fromView.superview];
        [UIView animateWithDuration:kFullScreenTransitionTime animations:^{
            // 这里动画属性设置的先后是有顺序的，先执行transform，后执行frame
            transitionView.transform = CGAffineTransformIdentity;
            transitionView.frame = frame;
            transitionMaskV.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [transitionMaskV removeFromSuperview];
            [self.playerManger setCurrentPlayerView:fromView];
            [self.playerManger setIsFullScreenMode:NO];
            if (completion) {
                completion();
            }
        }];
    }];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (!self.allowPortraitFullscreen) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)shouldAutorotate
{
    if (!self.allowPortraitFullscreen) {
        return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    } else {
        return YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return !_showStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

@end





@implementation UIViewController (FullScreenViewController)

// 旋转屏幕动画
- (void)presentViewController:(FullScreenViewController *)viewControllerToPresent fromView:(UIView<AVPlayerViewDelegate> *)fromView animated:(BOOL)animated completion:(void (^)(void))completion
{
    NSAssert(nil != fromView, @"fromView must not be nil!");
    if (animated) {
        [[UIApplication sharedApplication].keyWindow addSubview:viewControllerToPresent.view];
        viewControllerToPresent.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        FullScreenView * fullScreenView = viewControllerToPresent.fullScreenView;
        fullScreenView.hidden = YES;
        
        CGRect orginFrame = [viewControllerToPresent.view convertRect:fromView.frame fromView:fromView.superview];
        FullScreenView * trasitionView = [[FullScreenView alloc]initWithFrame:orginFrame type:FullScrenViewTypeTransition];
        trasitionView.frame = orginFrame;
        trasitionView.backgroundColor = [UIColor blackColor];
        [viewControllerToPresent.view addSubview:trasitionView];
        
        // player trans
        [viewControllerToPresent.playerManger setCurrentPlayerView:trasitionView];
        
        [UIView animateWithDuration:kFullScreenTransitionTime animations:^{
            CGFloat width = kScreenWidth;
            CGFloat height = kScreenHeight;
            
            trasitionView.frame = CGRectMake(-(height - width)/2, (height - width)/2, height, width);
            trasitionView.transform = CGAffineTransformMakeRotation(M_PI_2);
            viewControllerToPresent.view.backgroundColor = [UIColor blackColor];
        }completion:^(BOOL finished) {
            // player trans
            [trasitionView removeFromSuperview];
            [viewControllerToPresent.playerManger setCurrentPlayerView:fullScreenView];
            [viewControllerToPresent.playerManger setIsFullScreenMode:YES];
            
            fullScreenView.hidden = NO;
            [self presentViewController:viewControllerToPresent animated:NO completion:^{
                if (completion) {
                    completion();
                }
            }];
        }];
        
    }else {
        [self presentViewController:viewControllerToPresent animated:NO completion:completion];
    }
}


- (UIImage *)screenShotOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end




