//
//  NSObject+UIAlert.m
//  StarProject
//
//  Created by Roy lee on 15/10/16.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "NSObject+UIAlert.h"

@implementation NSObject (UIAlert)

- (id)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate completionHandle:(void(^)(NSUInteger buttonIndex, id alertView))handle buttonTitles:(NSString *)titles,...
{
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (titles != nil) {
        
        id eachObject;
        va_list argumentList;
        NSUInteger index = 0;
        
        // ①.添加第一个按钮的action
        UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:titles style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // 获取下标
            NSNumber * indexObj = objc_getAssociatedObject(action, "cancel action");
            NSUInteger currentIndex = [indexObj integerValue];
            if (handle) {
                handle(currentIndex,alert);
            }
        }];
        
        objc_setAssociatedObject(actionCancel, "cancel action", [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [alert addAction:actionCancel];
        index ++;
        
        // ②.创建参数列表
        va_start(argumentList, titles);
        
        // 获取参数，并执行操作
        while ((eachObject = va_arg(argumentList, id))) {
            // 添加action
            UIAlertAction * action = [UIAlertAction actionWithTitle:eachObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // 获取下标
                NSNumber * indexObj = objc_getAssociatedObject(action, "action");
                NSUInteger currentIndex = [indexObj integerValue];
                if (handle) {
                    handle(currentIndex,alert);
                }
            }];
            
            objc_setAssociatedObject(action, "action", [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [alert addAction:action];
            index ++;
        }
        va_end(argumentList);
    }
    
    if ([delegate isKindOfClass:[UIViewController class]]) {
        [delegate presentViewController:alert animated:YES completion:nil];
    }
    
    return alert;
#else
    objc_setAssociatedObject(self, "blockCallback", [handle copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                           message:message
                          delegate:self
                 cancelButtonTitle:nil
                 otherButtonTitles:nil];
        
    if (titles) {
        [alert addButtonWithTitle:titles];
    }
    
    id eachObject;
    va_list argumentList;
    
    // ①.创建参数列表
    va_start(argumentList, titles);
    // ②.获取参数，并执行操作
    while ((eachObject = va_arg(argumentList, id))) {
        [alert addButtonWithTitle:eachObject];
    }
    va_end(argumentList);
    
    alert.cancelButtonIndex = [alert numberOfButtons] - 1;
    [alert show];
    return alert;
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^block)(NSUInteger buttonIndex, UIAlertView *alertView) = objc_getAssociatedObject(self, "blockCallback");
    if (block) {
        block(buttonIndex, alertView);
    }
}

- (instancetype)actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIActionSheet *sheet, NSInteger index))block
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:destructiveTitle otherButtonTitles:nil, nil];
    
    for (NSString * titles in buttonTitles) {
        [actionSheet addButtonWithTitle:titles];
    }
    
    objc_setAssociatedObject(actionSheet, "action_sheet_dismiss_block", block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^didDismisssBlock)(UIActionSheet *sheet, NSInteger index) = objc_getAssociatedObject(actionSheet, "action_sheet_dismiss_block");
    if (didDismisssBlock) {
        didDismisssBlock(actionSheet,buttonIndex);
    }
}

@end
