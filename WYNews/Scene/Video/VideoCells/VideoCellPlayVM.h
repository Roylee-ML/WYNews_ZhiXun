//
//  VideoCellPlayVM.h
//  StarProject
//
//  Created by Roy lee on 16/1/16.
//  Copyright © 2016年 xmrk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPlayerManger.h"
#import "UserVideoCell.h"

@interface VideoCellPlayVMSource : NSObject

@property (nonatomic, strong) NSMutableArray * videoSource;

- (instancetype)initWithContainerController:(__weak UIViewController *)viewController
                                  tableView:(UIScrollView *)tableView
                                videoSource:(NSMutableArray *)videoSource;

@end


@interface VideoCellPlayVM : NSObject<AVPlayerDelegate,UserVideoCellDelegate>

@property (nonatomic, strong) VideoCellPlayVMSource * videoVMSource;
@property (nonatomic, strong) AVPlayerManger * playerManger;

- (instancetype)initWithVideoVMSource:(VideoCellPlayVMSource *)videoVMSource;

// 重置
- (void)resetUserVideoCellPlayStatus;

#pragma mark - TableViewDelegate M
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UIScrollView (Cell)

- (void)p_reloadData;

- (UIView *)p_cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)p_indexPathForCell:(UserVideoCell *)cell;

- (void)p_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

@end

