//
//  PopAniamtor.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "PopAniamtor.h"

@implementation PopAniamtor

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    __block CGRect toRect = toViewController.view.frame;
    CGFloat originX = toRect.origin.x;
    toRect.origin.x -= toRect.size.width / 3;
    toViewController.view.frame = toRect;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect fromRect = fromViewController.view.frame;
        fromRect.origin.x += fromRect.size.width;
        fromViewController.view.frame = fromRect;
        
        toRect.origin.x = originX;
        toViewController.view.frame = toRect;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
