//
//  NSObject+MessageSound.h
//  VVCarPooling
//
//  Created by roylee on 15/9/12.
//  Copyright (c) 2015年 gaoshunsheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extesion)


UIWindow * keyWindow();

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC;

-(void)heartAnimation:(UIButton *)sender;

@end
