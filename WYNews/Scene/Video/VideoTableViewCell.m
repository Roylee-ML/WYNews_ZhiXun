//
//  VideoTableViewCell.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "NSString+StringHeight.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define ALPH 0.7
#define CELL_HEIGHT SELF_WIDTH*0.77
#define LABLE_COLOR [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1]

@interface VideoTableViewCell()
{
    BOOL _isHidden;
    NSTimer * _myTimer;
    NSInteger _clickBT;
    UIImageView * _btImgView;
}
@end

@implementation VideoTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupViews];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1];
    }
    return self;
}

-(void)setupViews
{
//背景图
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, CELL_HEIGHT-SELF_WIDTH/70)];
    bgView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:240.0/255 alpha:1];
    [self.contentView addSubview:bgView];
    
//播放视图
    self.videoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH,CELL_HEIGHT*4/5)];
    _videoImgView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:_videoImgView];
    
//播放按钮
    _btImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*0.15, SELF_WIDTH*0.15)];
    _btImgView.image = [UIImage imageNamed:@"achi_cycle"];
    _btImgView.alpha = ALPH;
    _btImgView.center = _videoImgView.center;
    _btImgView.clipsToBounds = YES;
    [self.contentView addSubview:_btImgView];
    
    self.playVideoBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH*0.15, SELF_WIDTH*0.15)];
    _playVideoBT.layer.cornerRadius = _playPauseBT.frame.size.width/2;
    _playVideoBT.clipsToBounds =YES;
    _playVideoBT.backgroundColor = [UIColor clearColor];
    [_playVideoBT setImage:[[UIImage imageNamed:@"bofang"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    _playVideoBT.tintColor = [UIColor whiteColor];
    _playVideoBT.center = _videoImgView.center;
    [_playVideoBT addTarget:self action:@selector(didClickPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playVideoBT];
    
//创建描述文本lable
    self.descripLable = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_EDGE, _videoImgView.frame.size.height+SELF_WIDTH/200, SELF_WIDTH*4/5, SELF_WIDTH/15)];
    _descripLable.font = [UIFont boldSystemFontOfSize:15];
    _descripLable.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_descripLable];
    
/**/
//创建时间lable,以下所有视图以这个视图为基准，中心也以这个为准。
    self.timeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_EDGE, _descripLable.frame.size.height+_descripLable.frame.origin.y+SELF_WIDTH/200 -0.5, SELF_WIDTH/30-1.5, SELF_WIDTH/30-1.5)];
//    _timeImgView.backgroundColor = [UIColor greenColor];
    _timeImgView.image = [[UIImage imageNamed:TIME_ICON]imageWithColor:LABLE_COLOR];
//    _timeImgView.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_timeImgView];
    
    self.timeLable = [[UILabel alloc]initWithFrame:CGRectMake(_timeImgView.frame.origin.x+_timeImgView.frame.size.width+SELF_WIDTH/100, 0, SELF_WIDTH/6, SELF_WIDTH/18)];
    _timeLable.center = CGPointMake(_timeLable.center.x, _timeImgView.center.y);
    _timeLable.font = [UIFont systemFontOfSize:12];
    _timeLable.textAlignment = NSTextAlignmentLeft;
    _timeLable.textColor = LABLE_COLOR;
    [self.contentView addSubview:_timeLable];
    
//创建播放次数
    self.countImgView = [[UIImageView alloc]initWithFrame:CGRectMake(_timeLable.frame.size.width+_timeLable.frame.origin.x+SELF_WIDTH/200 + 1, 0, _timeImgView.frame.size.width +3, _timeImgView.frame.size.width +3)];
    _countImgView.center = CGPointMake(_countImgView.center.x, _timeImgView.center.y);
    _countImgView.image = [[UIImage imageNamed:PLAYCOUNT_ICON]imageWithColor:LABLE_COLOR];
    [self.contentView addSubview:_countImgView];
    
    self.playCountLable = [[UILabel alloc]initWithFrame:CGRectMake(_countImgView.frame.origin.x+_countImgView.frame.size.width + SELF_WIDTH/100, 0, SELF_WIDTH/5, _timeLable.frame.size.height)];
    _playCountLable.center = CGPointMake(_playCountLable.center.x, _timeImgView.center.y-0.5);
    _playCountLable.font = [UIFont systemFontOfSize:12];
    _playCountLable.textColor = LABLE_COLOR;
    [self.contentView addSubview:_playCountLable];
    
//创建跟帖背景图
    self.replayBGImgView = [[UIImageView alloc]initWithFrame:CGRectMake(SELF_WIDTH - (SELF_WIDTH/5+LEFT_EDGE), _timeImgView.frame.origin.y -1, SELF_WIDTH/5, _timeImgView.frame.size.height + 2)];
    _replayBGImgView.image = [[UIImage imageNamed:@"night_contentcell_comment_border"]imageWithColor:LABLE_COLOR];;
    _replayBGImgView.layer.cornerRadius = _replayBGImgView.frame.size.height/3;
//    _replayBGImgView.clipsToBounds = YES;
    [self.contentView addSubview:_replayBGImgView];
    
    self.replayLable = [[UILabel alloc]initWithFrame:CGRectMake(SELF_WIDTH - (SELF_WIDTH/5+LEFT_EDGE), 0, _replayBGImgView.frame.size.width-SELF_WIDTH/100, SELF_WIDTH*3/75)];
    _replayLable.center = CGPointMake(_replayLable.center.x, _timeLable.center.y);
    _replayLable.textAlignment = NSTextAlignmentRight;
    _replayLable.font = [UIFont systemFontOfSize:12];
    _replayLable.textColor = LABLE_COLOR;
    self.replayLable.numberOfLines = 1;
    [self.contentView addSubview:_replayLable];
    
}

-(void)setVideoModel:(VideoModel *)videoModel
{
    if (_videoModel != videoModel) {
        _videoModel = videoModel;
        
        [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:_videoModel.cover]];
        self.replayLable.text = [NSString stringWithFormat:@"%d 跟帖",_videoModel.replyCount];
        self.playCountLable.text = [NSString stringWithFormat:@"%d",_videoModel.playCount];
        self.timeLable.text = [NSString convertTime:_videoModel.length];
        self.descripLable.text = _videoModel.title;
        
        //动态改变文本的宽度
        CGFloat wideth = [NSString textLableWideth:[NSString stringWithFormat:@"%d 跟帖",_videoModel.replyCount] andFont:[UIFont systemFontOfSize:12.0]];
        
        self.replayLable.frame = CGRectMake(SELF_WIDTH-(LEFT_EDGE+wideth + 5), _replayLable.frame.origin.y, wideth, _replayLable.frame.size.height);
        
        self.replayBGImgView.frame = CGRectMake((SELF_WIDTH-LEFT_EDGE) - (_replayLable.frame.size.width +10), _replayBGImgView.frame.origin.y,_replayLable.frame.size.width + 10, _replayBGImgView.frame.size.height);
        
    }
}

- (void)didClickPlayVideo:(id)sender
{
    //移除开始按钮
    [self.playVideoBT setEnabled:NO];

    self.playVideoBT.alpha = 0;
    _btImgView.alpha = 0;
    
    self.playStatus = Playing;
    
    [self.playPauseBT setImage:[[UIImage imageNamed:@"zanting"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    self.videoBlock(self.videoImgView,self.playProgress,_videoModel.mp4_url);
    
    NSLog(@"videoMp4 ======== %@",_videoModel.mp4_url);
}

//创建开始按钮
-(void)showPlayButton
{
    [self.playVideoBT setEnabled:YES];
    
    _btImgView.alpha = ALPH;
    _playVideoBT.alpha = 1;
}

//隐藏开始按钮
-(void)hidePlayButton
{
    [self.playVideoBT setEnabled:NO];
    
    _btImgView.alpha = 0;
    _playVideoBT.alpha = 0;
}

#pragma mark ------ 显示播放控制视图 ------
-(void)showCotrollView
{
    _controllView.alpha = 1;
    _controllView.userInteractionEnabled = YES;
    [self showPlayProgress];
}

//创建进度指示视图
-(void)setupPlayStatusControllView
{
    
//创建视频操作视图
    _controllView = [[UIView alloc]initWithFrame:CGRectMake(0, self.videoImgView.frame.size.height - self.videoImgView.frame.size.height/8, self.videoImgView.frame.size.width, self.videoImgView.frame.size.height/8)];
    _controllView.backgroundColor = [UIColor clearColor];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _controllView.frame.size.width, _controllView.frame.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = ALPH;
    [_controllView addSubview:bgView];
    
    
    //1.创建暂停按钮
    self.playPauseBT = [[UIButton alloc]initWithFrame:CGRectMake(self.videoImgView.frame.size.width/10, self.videoImgView.frame.size.height/8/5, self.videoImgView.frame.size.height/8*3/5, self.videoImgView.frame.size.height/8*3/5)];
    
    [self setupPlayAndPauseBT];
    
    //添加事件
    [_playPauseBT addTarget:self action:@selector(didClickChangePlayStatus:) forControlEvents:UIControlEventTouchUpInside];
    _playPauseBT.tintColor = [UIColor whiteColor];
    
    [_controllView addSubview:_playPauseBT];
    
    //创建进度视图
    self.playProgress = [[UISlider alloc]initWithFrame:CGRectMake(self.videoImgView.frame.size.width/6, self.videoImgView.frame.size.height/8*(2.0/5), self.videoImgView.frame.size.width*(1-1.0/6)- self.videoImgView.frame.size.width/10, self.videoImgView.frame.size.height/8/5)];
    
    _playProgress.minimumValue = 0;
    _playProgress.maximumValue = 1;
    _playProgress.value = 0.0;
    _playProgress.minimumTrackTintColor = [UIColor whiteColor];
    _playProgress.maximumTrackTintColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1];
    
    UIImage * p_image = [[UIImage imageNamed:@"audionews_slider_dot"]imageWithColor:[UIColor whiteColor]];
    
    [_playProgress setThumbImage:p_image forState:UIControlStateNormal];
    [_playProgress setThumbImage:p_image forState:UIControlStateHighlighted];
    
    //添加拖动事件
    [_playProgress addTarget:self action:@selector(changePlayToTime) forControlEvents:UIControlEventValueChanged];
    
    [_controllView addSubview:_playProgress];
    
    //隐藏视图
    _controllView.alpha = 0;
    _controllView.userInteractionEnabled = NO;
    
//添加视频操作视图到contentview上
    [self.contentView addSubview:_controllView];
    
//注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recordClickTimes) name:@"playAndPause" object:nil];
    
}

//设置播放按钮状态
-(void)setupPlayAndPauseBT
{
    switch (_playStatus) {
        case 0:
            [_playPauseBT setImage:[[UIImage imageNamed:@"zanting"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            break;
        case 1:
            [_playPauseBT setImage:[[UIImage imageNamed:@"bofang"]imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

//暂停按钮事件触发操作
-(void)didClickChangePlayStatus:(UIButton*)button
{
    switch (_playStatus) {
        case 0:
            //正在播放时，点击按钮切换成播放按钮
            [_playPauseBT setImage:[[UIImage imageNamed:@"bofang"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            //改变播放状态
            self.playStatus = Pause;
            
            self.playBlock(Pause);
            
            break;
        case 1:
            //暂停时，点击按钮切换成播放模式，按钮切换成暂停按钮
            [_playPauseBT setImage:[[UIImage imageNamed:@"zanting"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            //改变播放状态
            self.playStatus = Playing;
            
            self.playBlock(Playing);
            
            break;
        default:
            break;
    }
    
    //建立通知，解决单位时间内没有点击事件就自动消失
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playAndPause" object:nil];
    
}

#pragma matk ------ 改变播放时间状态 ------
-(void)changePlayToTime
{
    
    CGFloat toTime = self.playProgress.value;
    
    CGFloat currentBuffer = [[OnePlayer onePlayer]currentBuffer];
    
    //改变后的播放时间要小于缓存进度
    if (toTime <= currentBuffer) {
        [[OnePlayer onePlayer]seekToCustomTimeByHandle:^CGFloat{
            return toTime;
        }];
    }else{
        //还原slider位置
        self.playProgress.value = CMTimeGetSeconds([[OnePlayer onePlayer]currentTime])/[OnePlayer onePlayer].totalTime;
    }
}

#pragma mark ------ 记录播放进度 ------
-(void)showPlayProgress
{
    __weak VideoTableViewCell * sself = self;
    
    [[OnePlayer onePlayer]changePlayProgressByHandle:^(CGFloat percentage) {
        
        sself.playProgress.value = percentage;
//        NSLog(@"percentage === %.3f",percentage);
//        NSLog(@"value ======== %3.f",sself.playProgress.value);
//        NSLog(@"playprogress = %@",sself.playProgress);
        
    } andDownProgressByHandle:^(CGFloat percentage) {
        
    }];
}

//记录点击次数延时消失controllView
-(void)recordClickTimes
{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    NSString * str = @"firstTime";
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideControllView) userInfo:str repeats:NO];
}

-(void)hideControllView
{
//    [_controllView setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        _controllView.alpha = 0;
        _controllView.userInteractionEnabled = NO;
        
    }];
   
}

-(void)hideControllViewRightNow
{
    _controllView.alpha = 0;
    _controllView.userInteractionEnabled = NO;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}




- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
