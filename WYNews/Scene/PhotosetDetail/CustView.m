//
//  CustView.m
//  haha
//
//  Created by lanou3g on 15/6/3.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CustView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface CustView()
{
    CGFloat _orginScale;
    CGPoint _orginPoint;
    CGFloat _dx;
}
@end

@implementation CustView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        
        //创建imageView
        self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //设置自定义scrollerView属性
        self.minimumZoomScale = 0.6;
        self.maximumZoomScale = 10;
        self.bounces = NO;
        self.bouncesZoom = YES;
        self.clipsToBounds = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        //设置imageView属性(根据比例展示在imageView上)
        _imageView.clipsToBounds = YES;
        //添加imageView到自定义轮播视图
        [self addSubview:_imageView];
        
        self.contentMode = UIViewContentModeCenter;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.delegate = self;
        
        //添加轻拍手势
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeImageViewScale:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


//返回要缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark ---- 重新设置imageView的frame，改变contentSize ----
-(void)resetImageViewFrame
{
    if (self.imageView.image) {
        
        CGFloat ratio = self.imageView.image.size.height/self.imageView.image.size.width;
        CGSize newContentSize;
        if (self.zoomScale >= 1) {
            newContentSize = CGSizeMake(self.contentSize.width, (self.contentSize.width * ratio >= self.frame.size.height ? self.contentSize.width * ratio : self.frame.size.height));
            
            self.contentSize = newContentSize;
        }
        
        CGRect frame = _imageView.frame;
        frame.size.width = self.contentSize.width;
        frame.size.height = self.contentSize.height;
        _imageView.frame = frame;
    }
}

//视图滚动后恢复大小重置frame
-(void)resetFrame
{
    CGRect frame = self.frame;
    frame.origin = CGPointMake(0, 0);
    
    self.imageView.frame = frame;
}

#pragma mark ---- ScrollViewDelegate -----

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat d_scale = self.zoomScale - _orginScale;
    _orginScale = self.zoomScale;
    
    if (self.zoomScale<1) {
        _imageView.center =  CGPointMake(SCREEN_WIDTH/2, self.center.y);
        
        self.contentSize = CGSizeMake(self.contentSize.width, self.frame.size.height);
    }else{
        if (d_scale < 0) {  //正在缩小
            [self resetImageViewFrame];
        }
    }
    
    NSLog(@"++frame === %.2f  %.2f , zoomScale = %.2f",self.contentSize.width,self.contentSize.height,self.zoomScale);
/*
    //保证缩放中心
    CGFloat Ws = self.frame.size.width - self.contentInset.left - self.contentInset.right;
    CGFloat Hs = self.frame.size.height - self.contentInset.top - self.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rect = _imageView.frame;
    rect.origin.x = MAX((Ws-W)/2, 0);
    rect.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rect;
    
    NSLog(@"scrollview - offset_x = %.2f,offset_y = %.2f   imageview - width = %.2f,height = %.2f",self.contentSize.width,self.contentSize.height,_imageView.frame.size.width,_imageView.frame.size.height);
    NSLog(@"imageFrame - imageWidth = %.2f,imageHeight = %.2f",_imageView.image.size.width,_imageView.image.size.height);
*/
}

//缩放结束
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _orginScale = self.zoomScale;
    
    [self resetImageViewFrame];
    
    if (self.zoomScale < 1) {
        self.zoomScale = 1;
        
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    _imageView.center = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    
    NSLog(@"--frame === %.2f  %.2f",self.contentSize.width,self.contentSize.height);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"offset ===== %.2f , %.2f",scrollView.contentOffset.x,scrollView.contentOffset.x + self.frame.size.width);
}

-(void)changeImageViewScale:(UITapGestureRecognizer*)tapGesture
{
    self.zoomScale = 1;
    _imageView.center = CGPointMake(SCREEN_WIDTH/2, self.center.y);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _orginPoint = [[touches anyObject] locationInView:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    _dx = currentPoint.x - _orginPoint.x;
}

//手势截获处理
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"执行了手势方法-----offset = %.2f ,contentSize = %.2f , frame = %.2f",self.contentOffset.x,self.contentSize.width,self.frame.size.width);
//    
//    if (self.zoomScale > 1) {
//        if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
//            return YES;
//        }else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
//            
//            UIScrollView * superView = (UIScrollView*)self.superview;
//            UIPanGestureRecognizer * pan = (UIPanGestureRecognizer*)gestureRecognizer;
//            CGPoint transalition = [pan translationInView:superView];
//            NSLog(@"translition = %.2f",transalition.x);
//            if (self.contentOffset.x <= 0) {
//                if (transalition.x < 0) {
//                    
//                    NSLog(@"向左滑动收拾%.2f.......",transalition.x);
//                    return YES;
//                }else{
//                    
//                    NSLog(@"向右滑动收拾%.2f.......",transalition.x);
//                    return NO;
//                }
//            }else if ((self.contentOffset.x + self.frame.size.width + 1) >= self.contentSize.width) {
//                if (transalition.x > 0) {
//                    
//                    NSLog(@"向右滑动收拾%.2f.......",transalition.x);
//                    return YES;
//                }else{
//                    NSLog(@"向左滑动收拾%.2f.......",transalition.x);
//                    return NO;
//                }
//            }
//        }
//    }
    
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    NSLog(@"执行了手势方法-----offset = %.2f ,contentSize = %.2f , frame = %.2f",self.contentOffset.x,self.contentSize.width,self.frame.size.width);
//    
//    if (self.zoomScale > 1) {
//        if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
//            return YES;
//        }else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
//            
//            UIScrollView * superView = (UIScrollView*)self.superview;
//            UIPanGestureRecognizer * pan = (UIPanGestureRecognizer*)gestureRecognizer;
//            CGPoint transalition = [pan translationInView:superView];
//            NSLog(@"translition = %.2f",transalition.x);
//            if (self.contentOffset.x <= 0) {
//                if (transalition.x < 0) {
//                    
//                    NSLog(@"0==向左滑动手势%.2f.......",transalition.x);
//                    return YES;
//                }else{
//                    [pan requireGestureRecognizerToFail:gestureRecognizer];
//                    NSLog(@"0==向右滑动手势%.2f.......",transalition.x);
//                    return NO;
//                }
//            }else if ((self.contentOffset.x + self.frame.size.width + 1) >= self.contentSize.width) {
//                if (transalition.x > 0) {
//                    
//                    NSLog(@"1==向右滑动手势%.2f.......",transalition.x);
//                    return YES;
//                }else{
//                    [pan requireGestureRecognizerToFail:gestureRecognizer];
//                    NSLog(@"1==向左滑动手势%.2f.......",transalition.x);
//                    return NO;
//                }
//            }
//        }
//    }

//    if ([self.superview isKindOfClass:[UIScrollView class]]) {
//        UIScrollView * superView = (UIScrollView*)self.superview;
//        
//    }
    return YES;
}

//手势设置
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    if (self.zoomScale > 1) {
//        if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
//            return YES;
//        }else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
//            
//            UIScrollView * superView = (UIScrollView*)self.superview;
//            UIPanGestureRecognizer * pan = (UIPanGestureRecognizer*)gestureRecognizer;
//            CGPoint transalition = [pan translationInView:superView];
//            NSLog(@"translition = %.2f",transalition.x);
//            if (self.contentOffset.x <= 0) {
//                if (transalition.x < 0) {
//                    
//                    NSLog(@"0==向左滑动手势%.2f.......",transalition.x);
//                    return NO;
//                }else{
//                    [pan requireGestureRecognizerToFail:gestureRecognizer];
//                    NSLog(@"0==向右滑动手势%.2f.......",transalition.x);
//                    return YES;
//                }
//            }else if ((self.contentOffset.x + self.frame.size.width + 1) >= self.contentSize.width) {
//                if (transalition.x > 0) {
//                    
//                    NSLog(@"1==向右滑动手势%.2f.......",transalition.x);
//                    return NO;
//                }else{
//                    [pan requireGestureRecognizerToFail:gestureRecognizer];
//                    NSLog(@"1==向左滑动手势%.2f.......",transalition.x);
//                    return YES;
//                }
//            }
//        }
//    }
    
    return NO;
}


@end
