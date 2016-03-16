//
//  VideoSortPlayController.h
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoSortPlayController : UIViewController

@property (nonatomic, strong) NSString * sort_id;

- (instancetype)initWithSortID:(NSString *)sort_id;

@end
