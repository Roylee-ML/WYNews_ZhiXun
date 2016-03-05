//
//  AudiioAnimateView.h
//  WYNews
//
//  Created by lanou3g on 15/6/5.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(BOOL, AnimateRequest) {
    Animating,
    AnimateNone
};

@interface AudioAnimateView : UIView

@property (nonatomic,assign) BOOL isAnimating;
@property (nonatomic,strong) NSTimer * myTimer;

-(instancetype)initWithFrame:(CGRect)frame andImages:(NSArray*)imagesArray;

//布局视图
//-(void)animatWithOrder:(AnimateRequest)order;

//播放
-(void)animate;

//暂停
-(void)stopAnimate;

//重置出事化并暂停动画image
-(void)resetAnimateAndPause;

//切换父视图
-(void)exchangerSuperViewTo:(UIView*)secondView;

//移除
-(void)removeAnimate;




@end
