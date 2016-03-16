//
//  VideoSortHeaderBar.h
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VideoSortHeaderBar : UIView

@property (nonatomic, strong) NSArray * sorts;
@property (nonatomic, copy) void(^headerSortBarDidSelectedItemBlock)(MVideoSort * sort,NSInteger index);

@end
