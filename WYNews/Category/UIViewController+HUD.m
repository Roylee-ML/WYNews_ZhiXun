/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "UIViewController+HUD.h"

#import "MBProgressHUD.h"
#import <objc/runtime.h>
#import "UIImage+ImageWithColor.h"

#define kDefaultOffSet_Y      0
#define kDefaultLableFont     16
#define kDefaultSquareLength  7
#define kMinHudSize           CGSizeMake(110, 110)
#define kDefaultMargin        10.0f
#define kDefaultHidenDuration 1.0f
#define kLoadingTintColor     [[UIColor blackColor] colorWithAlphaComponent:0.5]
#define kCompleteTintColor    [[UIColor blackColor] colorWithAlphaComponent:0.65]

static const void *AssociatedHUDKey = &AssociatedHUDKey;

@interface UIViewController ()

@property (nonatomic, assign) BOOL isNavAlertShowing;

@end

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, AssociatedHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    [self willChangeValueForKey:@"HUD"];
    objc_setAssociatedObject(self, AssociatedHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"HUD"];
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.labelText = hint;
    HUD.minSize = kMinHudSize;
    HUD.square = hint.length <= kDefaultSquareLength;
    HUD.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    HUD.color = kLoadingTintColor;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.minSize = kMinHudSize;
    hud.square = hint.length <= kDefaultSquareLength;
    hud.yOffset = kDefaultOffSet_Y;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset {
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.minSize = kMinHudSize;
    hud.square = hint.length <= kDefaultSquareLength;
    hud.yOffset = kDefaultOffSet_Y;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
}

- (void)showSucessHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operationbox_successful"]];
    hud.labelText = hint?hint:@"操作成功";
    hud.square = hint.length <= kDefaultSquareLength;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.minSize = kMinHudSize;
    hud.yOffset = kDefaultOffSet_Y;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
}

- (void)hideHud{
    if (self.HUD) {
        [[self HUD] hide:YES];
    }
}

void MBShowHudInView(UIViewController * self,NSString * hint){
    [self hideHud];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.minSize = kMinHudSize;
    hud.margin = kDefaultMargin;
    hud.color = kLoadingTintColor;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.square = hint.length <= kDefaultSquareLength;
    [self.view addSubview:hud];
    [hud show:YES];
    [self setHUD:hud];
}

void MBShowHint(UIViewController * self,NSString * hint){
    [self hideHud];
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.minSize = kMinHudSize;
    hud.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.labelText = hint;
    hud.square = hint.length <= kDefaultSquareLength;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.yOffset = kDefaultOffSet_Y;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
//    [self setHUD:hud];
}

void MBShowProgress(UIViewController * self,NSString * hint){
    [self hideHud];
    //显示提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = YES;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.minSize = kMinHudSize;
    hud.color = kLoadingTintColor;
    hud.labelText = hint;
    hud.square = hint.length <= kDefaultSquareLength;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.yOffset = kDefaultOffSet_Y;
    hud.removeFromSuperViewOnHide = YES;
    [self setHUD:hud];
}

void MBSetProgress(UIViewController * self,CGFloat progress){
    MBProgressHUD *hud = [self HUD];
    if (hud.mode == MBProgressHUDModeAnnularDeterminate) {
        [hud setProgress:progress];
    }
}

void MBShowSucessHint(UIViewController * self,NSString * hint){
    [self hideHud];
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"operationbox_successful"] imageWithColor:[UIColor whiteColor]]];
    hud.labelText = hint?hint:@"操作成功";
    hud.square = hint.length <= kDefaultSquareLength;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.minSize = kMinHudSize;
    hud.yOffset = kDefaultOffSet_Y;
    hud.color = kCompleteTintColor;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
//    [self setHUD:hud];
}

void MBShowErrorHint(UIViewController * self,NSString * hint){
    [self hideHud];
    //显示提示信息
    UIView *view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operationbox_error"]];
    hud.labelText = hint?hint:@"操作失败";
    hud.square = hint.length <= kDefaultSquareLength;
    hud.labelFont = [UIFont systemFontOfSize:kDefaultLableFont];
    hud.margin = kDefaultMargin;
    hud.minSize = kMinHudSize;
    hud.yOffset = kDefaultOffSet_Y;
    hud.color = kCompleteTintColor;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:kDefaultHidenDuration];
//    [self setHUD:hud];
}

void MBHideHud(UIViewController * self){
    [self hideHud];
}


#pragma mark - Navigation Alert

void ShowNavigationBarAlert(UIViewController * self, NSString * title)
{
    if (!self.navigationController) {
        return;
    }
    // 避免反复多次下拉弹出多个提示框
    if (self.isNavAlertShowing) {
        return;
    }
    self.isNavAlertShowing = YES;
    //1.创建 Label
    CGFloat navHeight = self.navigationController.navigationBar.size.height;
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, navHeight - 35, kScreenWidth, 35)];
    label.backgroundColor = RGBCOLORA(76, 81, 93, 0.8);
    
    //2.设置其他属性
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    //3.添加
    [self.navigationController.navigationBar insertSubview:label atIndex:0];
    
    //4.动画
    CGFloat duration = 1.0;
    [UIView animateWithDuration:duration animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, label.frame.size.height);
    } completion:^(BOOL finished) {
        CGFloat delay = 1.0;
        //options:动画运动状态
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            //自动 回到原来的位置
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
            self.isNavAlertShowing = NO;
        }];
    }];
}

- (BOOL)isNavAlertShowing
{
    return [objc_getAssociatedObject(self, "obj_isalerting") boolValue];
}

- (void)setIsNavAlertShowing:(BOOL)isNavAlertShowing
{
    [self willChangeValueForKey:@"isNavAlerting"];
    objc_setAssociatedObject(self, "obj_isalerting", @(isNavAlertShowing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"isNavAlerting"];
}


@end
