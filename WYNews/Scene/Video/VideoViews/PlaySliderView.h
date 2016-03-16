//
//  PlaySliderView.h
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaySliderView;
typedef void(^PlaySliderViewAction)(PlaySliderView * slider);

@interface PlaySliderView : UISlider

@property (nonatomic, strong) UIProgressView * bufferProgress;
@property (nonatomic, assign) BOOL isDragging;

- (void)addTouchBeganAction:(PlaySliderViewAction)touchBeganAction;

- (void)addTouchEndAction:(PlaySliderViewAction)touchEndAction;

- (void)addTouchValueChangedAction:(PlaySliderViewAction)valueChangedAction;

- (void)setProgress:(float)progress animated:(BOOL)animated;

- (float)progress;

@end
