//
//  VideoCellPlayVM.m
//  StarProject
//
//  Created by Roy lee on 16/1/16.
//  Copyright © 2016年 xmrk. All rights reserved.
//

#import "VideoCellPlayVM.h"
#import "MVideo.h"
#import "FullScreenViewController.h"
#include "NSObject+UIAlert.h"

@interface VideoCellPlayVMSource ()

@property (nonatomic, strong) UIScrollView * tableView; // 支持tableview 与 collectionview
@property (nonatomic, weak) UIViewController * containerVC;

@end

@implementation VideoCellPlayVMSource

- (instancetype)initWithContainerController:(__weak UIViewController *)viewController tableView:(UIScrollView *)tableView videoSource:(NSMutableArray *)videoSource
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.videoSource = videoSource;
    self.containerVC = viewController;
    self.tableView = tableView;
    return self;
}

@end





@interface VideoCellPlayVM ()

@property (nonatomic, strong) NSIndexPath * playingIndexPath;

@end

@implementation VideoCellPlayVM

- (void)dealloc {
    [self.playerManger pauseContent];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.playerManger = nil;
    self.videoVMSource = nil;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

- (instancetype)initWithVideoVMSource:(VideoCellPlayVMSource *)videoVMSource {
    self = [self init];
    if (!self) {
        return nil;
    }
    self.videoVMSource = videoVMSource;
    self.playerManger = [[AVPlayerManger alloc]initWithPlayerView:nil];
    self.playerManger.delegate = self;
    return self;
}

// 重置
- (void)resetUserVideoCellPlayStatus {
    [self.playerManger clearPlayer];
    
    if (!_playingIndexPath || _playingIndexPath.row > self.videoVMSource.videoSource.count - 1) {
        return;
    }
    UserVideoCell * cell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:_playingIndexPath];
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:_playingIndexPath.row];
    video.statusLayout.playStatus = VideoPlayStatusNormal;
    video.statusLayout.progress = 0.0;
    [cell configCellWith:video];
    self.playingIndexPath = nil;
}

#pragma mark - UIApplication Notify
- (void)applicationWillResignActive {
    [self resetUserVideoCellPlayStatus];
}

- (void)applicationDidBecomeActive {
    
}

#pragma mark - Net Status Judge
- (void)judgeNetStatusCompletion:(void(^)(BOOL shouldPlay))completion {
    NSString * state = [ShareManger networkingStatusFromStatebar];
    
    if ([state isEqualToString:@"notReachable"]) {
        [self showAlertWithTitle:@"提示" message:@"您当前的网络不可用" delegate:self.videoVMSource.containerVC completionHandle:^(NSUInteger buttonIndex, id alertView) {
            
        } buttonTitles:@"知道了",nil];
        completion(NO);
    }else if (![state isEqualToString:@"wifi"]) {
        [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"您当前使用的是%@网络状态，确定要继续播放吗？",state] delegate:self.videoVMSource.containerVC completionHandle:^(NSUInteger buttonIndex, id alertView) {
            completion(buttonIndex == 1);
        } buttonTitles:@"取消播放",@"继续播放",nil];
        return;
    }
    completion(YES);
}

#pragma mark  - UserVideoCellDelegate

- (void)userVideoCell:(UserVideoCell *)cell startPlay:(MVideo *)video {
    @weakify(self);
    [self judgeNetStatusCompletion:^(BOOL shouldPlay) {
        @strongify(self);
        if (shouldPlay) {
            if (video.statusLayout.playStatus == VideoPlayStatusPause) {
                video.statusLayout.playStatus = VideoPlayStatusPlaying;
                [self.playerManger playContent];
                [cell refreshPlayViewBy:video isOnlyProgress:NO];
                return;
            }
            // old cell refresh
            if (self.playingIndexPath) {
                MVideo * oldVideo = [self.videoVMSource.videoSource objectAtIndex:self.playingIndexPath.row];
                oldVideo.statusLayout.playStatus = VideoPlayStatusNormal;
                oldVideo.statusLayout.totalTime = 0.0;
                oldVideo.statusLayout.progress = 0.0f;
                oldVideo.statusLayout.buffer = 0.0f;
                
                UserVideoCell * oldCell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:self.playingIndexPath];
                [oldCell refreshPlayViewBy:oldVideo isOnlyProgress:NO];
            }
            // refresh cell
            NSIndexPath * indexPath = [self.videoVMSource.tableView p_indexPathForCell:cell];
            self.playingIndexPath = indexPath;
            video.statusLayout.playStatus = VideoPlayStatusBeginPlay;
            video.statusLayout.totalTime = [self.playerManger.player currentItemDuration];
            NSLog(@"totaltime === %.2f",video.statusLayout.totalTime);
            
            // play
            AVPlayerTrack * track = [[AVPlayerTrack alloc]initWithStreamURL:[NSURL URLWithString:video.m3u8Url]];
            [track setItemIndexPath:indexPath];
            [self.playerManger setCurrentPlayerView:cell.playView];
            [self.playerManger loadVideoWithTrack:track];
            
            // play count
            video.playCount ++;
            
            // reload data
            /*
             *  刷新不采用reloadata方法，而是个别位置的针对刷新，避免整体上UI的影响
             */
            [cell refreshPlayViewBy:video isOnlyProgress:NO];
        }
    }];
    
}

- (void)userVideoCell:(UserVideoCell *)cell playPuse:(MVideo *)video {
    if (video.statusLayout.playStatus == VideoPlayStatusPlaying) {
        video.statusLayout.playStatus = VideoPlayStatusPause;
        [self.playerManger pauseContent];
    }else if (video.statusLayout.playStatus == VideoPlayStatusPause) {
        video.statusLayout.playStatus = VideoPlayStatusPlaying;
        [self.playerManger playContent];
    }
    [cell refreshPlayViewBy:video isOnlyProgress:NO];
}

- (void)userVideoCell:(UserVideoCell *)cell fullScreenBt:(UIButton *)fullScreenBt {
    // go on play
    UIView<AVPlayerViewDelegate> * fromView = cell.playView;
    FullScreenViewController * fullScreenVC = [[FullScreenViewController alloc]initWithAVPlayerManger:self.playerManger video:self.videoVMSource.videoSource[_playingIndexPath.row]];
    // transition from view
    fullScreenVC.dismissFromViewBlock = ^UIView<AVPlayerViewDelegate> *(){
        UserVideoCell * fromCell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:self.playingIndexPath];
        return fromCell.playView;
    };
    // dismiss action
    fullScreenVC.dismissBlock = ^(BOOL isPlayEnd){
        self.playerManger.delegate = self;
        MVideo * video = self.videoVMSource.videoSource[_playingIndexPath.row];
        if (isPlayEnd) {
            video.statusLayout.playStatus = VideoPlayStatusEndPlay;
        }
        UserVideoCell * nowCell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:_playingIndexPath];
        [nowCell refreshPlayViewBy:video isOnlyProgress:NO];
    };
    [self.videoVMSource.containerVC presentViewController:fullScreenVC fromView:fromView animated:YES completion:nil];
}

- (void)userVideoCell:(UserVideoCell *)cell changePlayProgress:(CGFloat)percentTime {
    NSIndexPath * indexPath  = [self.videoVMSource.tableView p_indexPathForCell:cell];
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:indexPath.row];
    video.statusLayout.progress = percentTime;
    
    NSTimeInterval time = percentTime * [self.playerManger.player currentItemDuration];
    [self.playerManger seekToTimeInSecond:time completionHandler:^(BOOL finished) {
        
    }];
}

- (void)userVideoCell:(UserVideoCell *)cell toolBarClickedAtIndex:(NSInteger)index {
    NSIndexPath * indexPath = [self.videoVMSource.tableView p_indexPathForCell:cell];
    MVideo * video = self.videoVMSource.videoSource[indexPath.row];
    // 评论
    if (index == 0) {
        NSLog(@"点击了评论，跳转评论页面repl_id：%@",video.reply_id);
    }
    // 分享
    if (index == 1) {
        NSLog(@"点击了分享...........");
    }
}


#pragma mark - AVPlayerDelegate
- (void)videoPlayer:(AVPlayerManger*)playerManger didChangeStateTo:(AVPlayerState)fromState {
    
}

- (void)videoPlayer:(AVPlayerManger*)playerManger willStartVideo:(id<AVPlayerTrackProtocol>)track {
    
}

- (void)videoPlayer:(AVPlayerManger*)playerManger didStartVideo:(id<AVPlayerTrackProtocol>)track {
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:track.itemIndexPath.row];
    video.statusLayout.playStatus = VideoPlayStatusPlaying;
    video.statusLayout.totalTime = [playerManger.player currentItemDuration];
    
    UserVideoCell * cell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:track.itemIndexPath];
    [cell refreshPlayViewBy:video isOnlyProgress:NO];
}

- (void)videoPlayer:(AVPlayerManger *)playerManger isBuffering:(BOOL)buffering {
    
}

- (void)videoPlayer:(AVPlayerManger *)playerManger
   didCurrentBuffer:(double)currentBf
        totalBuffer:(double)totalBf {
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:_playingIndexPath.row];
    video.statusLayout.buffer = currentBf/totalBf;
    
    UserVideoCell * cell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:_playingIndexPath];
    [cell refreshPlayViewBy:video isOnlyProgress:YES];
}

- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayFrame:(id<AVPlayerTrackProtocol>)track time:(NSTimeInterval)time lastTime:(NSTimeInterval)lastTime {
    UserVideoCell * cell = (UserVideoCell *)[self.videoVMSource.tableView p_cellForRowAtIndexPath:track.itemIndexPath];
    if (cell.playView.isSliderDragging) {
        return;
    }
    
    CGFloat percent = time/[self.playerManger.player currentItemDuration];
    
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:track.itemIndexPath.row];
    video.statusLayout.progress = percent;
    video.statusLayout.currentTime = [playerManger.player currentNSTime];
    
    [cell refreshPlayViewBy:video isOnlyProgress:YES];
}

- (void)videoPlayer:(AVPlayerManger*)playerManger didPlayToEnd:(id<AVPlayerTrackProtocol>)track {
    MVideo * video = [self.videoVMSource.videoSource objectAtIndex:track.itemIndexPath.row];
    video.statusLayout.playStatus = VideoPlayStatusEndPlay;
    video.statusLayout.progress = 0.0f;
    video.statusLayout.buffer = 0.0f;
    
    UserVideoCell * cell = (UserVideoCell*)[self.videoVMSource.tableView p_cellForRowAtIndexPath:track.itemIndexPath];
    [cell refreshPlayViewBy:video isOnlyProgress:NO];
}

- (void)handleErrorCode:(AVPlayerErrorCode)errorCode track:(id<AVPlayerTrackProtocol>)track customMessage:(NSString*)customMessage {
    
}

#pragma mark - TableViewDelegate M
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end




@implementation UIScrollView (Cell)

- (UIView *)p_cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isKindOfClass:UITableView.class]) {
        UITableView * tableView = (UITableView *)self;
        return [tableView cellForRowAtIndexPath:indexPath];
    }
    if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView * collectionView = (UICollectionView *)self;
        return [collectionView cellForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (void)p_reloadData {
    [self performSelector:@selector(reloadData)];
}

- (NSIndexPath *)p_indexPathForCell:(UserVideoCell *)cell {
    if ([self isKindOfClass:UITableView.class]) {
        UITableView * tableView = (UITableView *)self;
        return [tableView indexPathForCell:cell];
    }
    if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView * collectionView = (UICollectionView *)self;
        return [collectionView indexPathForCell:(UICollectionViewCell *)cell.superview];
    }
    return nil;
}

- (void)p_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if ([self isKindOfClass:UITableView.class]) {
        UITableView * tableView = (UITableView *)self;
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView * collectionView = (UICollectionView *)self;
        [collectionView deleteItemsAtIndexPaths:indexPaths];
    }
}


@end

