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

/*!
 *  @VideoCellPlayVM 作为视频播放cell的viewModel代理，所有播放的操作均由这个类完成
 *  @VideoCellPlayVMSource 作为 VideoCellPlayVM 的数据源，存储视频的数据源，以及tableview与ViewController.因此，所有的数据都是存储在这个类的对象中，所以当用户网络请求或者其他操作更新数据的时候，VideoCellPlayVMSource 的数据源数组 videoSource 也要及时得到更新
 */

@interface VideoCellPlayVMSource : NSObject

@property (nonatomic, strong) NSMutableArray * videoSource;
@property (nonatomic, strong, readonly) MVideo * playingVideo;

- (instancetype)initWithContainerController:(__weak UIViewController *)viewController
                                  tableView:(UIScrollView *)tableView
                                videoSource:(NSMutableArray *)videoSource;

@end


@interface VideoCellPlayVM : NSObject<AVPlayerDelegate,UserVideoCellDelegate>

@property (nonatomic, strong) VideoCellPlayVMSource * videoVMSource;
@property (nonatomic, strong) AVPlayerManger * playerManger;
@property (nonatomic, strong) UIView * playingCell;

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

