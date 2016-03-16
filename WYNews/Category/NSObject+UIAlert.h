//
//  NSObject+UIAlert.h
//  StarProject
//
//  Created by Roy lee on 15/10/16.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UIAlert)<UIAlertViewDelegate,UIActionSheetDelegate>

- (id)showAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(UIViewController *)delegate completionHandle:(void(^)(NSUInteger buttonIndex, id alertView))handle buttonTitles:(NSString *)titles,...;

- (instancetype)actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIActionSheet *sheet, NSInteger index))block;

@end
