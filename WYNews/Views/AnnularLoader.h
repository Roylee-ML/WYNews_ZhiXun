//
//  AnnularLoader.h
//  StarProject
//
//  Created by Roy lee on 16/3/17.
//  Copyright © 2016年 xmrk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnularLoader : UIView

@property (nonatomic, strong) NSArray * colorArray;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGPoint offset;

- (void)startAnimation;
- (void)stopAnimation;
- (void)stopAnimationAfter:(NSTimeInterval)timeInterval;
- (BOOL)isAnimating;

@end
