//
//  SCPopView.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCPopViewDelegate <NSObject>

@optional
- (void)viewHeight:(CGFloat)height;
- (void)itemPressedWithIndex:(NSInteger)index;

@end

@interface SCPopView : UIView

@property (nonatomic, weak)     id<SCPopViewDelegate>delegate;
@property (nonatomic, strong)   NSArray *itemNames;
@property (nonatomic,assign)    CGFloat titleHeight;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
