/* Copyright (C) 2012 IGN Entertainment, Inc. */

#import <UIKit/UIKit.h>
#import "FullScreenView.h"
#import "AVPlayerManger.h"

@interface FullScreenViewController : UIViewController

@property (nonatomic) BOOL allowPortraitFullscreen;

@property (nonatomic, strong) FullScreenView *fullScreenView;
// tableview在present与dimiss后会自动reloaddata
@property (nonatomic, copy) UIView<AVPlayerViewDelegate> *(^dismissFromViewBlock)();
@property (nonatomic, copy) void(^dismissBlock)(BOOL isPlayEnd);

- (instancetype)initWithAVPlayerManger:(AVPlayerManger *)playerManger video:(id)video;

@end


@interface UIViewController (FullScreenViewController)

- (void)presentViewController:(FullScreenViewController *)viewControllerToPresent fromView:(UIView<AVPlayerViewDelegate> *)fromView animated:(BOOL)animated completion:(void (^)(void))completion;

@end
