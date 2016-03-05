//
//  FMlistTableViewCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMlistTableViewCell.h"
#import "OnePlayer.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height

@interface FMlistTableViewCell()

@property (nonatomic,strong) UIImageView * downloadingImgView;
@property (nonatomic,strong) UIImageView * downloadBGImgView;
@property (nonatomic,strong) NSTimer * dl_ingTimer;

@end


@implementation FMlistTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupViews];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:224.0/255 alpha:1];
        
    }
    return self;
}

-(void)setupViews
{
//    self.bgView = [[UIView alloc]initWithFrame:self.frame];
//    [self.contentView addSubview:_bgView];
    
    //标题
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_EDGE, SELF_WIDTH/80, SELF_WIDTH*4/5, SELF_WIDTH/10)];
    _titleLable.font = [UIFont boldSystemFontOfSize:16];
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.text = @"";
    
    [self.contentView addSubview:_titleLable];
    //时间
    self.timeLable = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_EDGE, _titleLable.frame.size.height, SELF_WIDTH/3, SELF_WIDTH/30)];
    _timeLable.font = [UIFont systemFontOfSize:12];
    _timeLable.text = @"";
    
    [self.contentView addSubview:_timeLable];
    
    //下载按钮背景图片，用于显示正在进行下载
    self.downloadingImgView = [[UIImageView alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/15 - LEFT_EDGE, _titleLable.frame.origin.y + SELF_WIDTH/30, SELF_WIDTH/15, SELF_WIDTH/15)];
    _downloadingImgView.clipsToBounds = YES;
    _downloadingImgView.layer.cornerRadius = _downloadingImgView.frame.size.width/2;
    _downloadingImgView.userInteractionEnabled = NO;
    _downloadingImgView.backgroundColor = [UIColor clearColor];
    
    //下载完成背景图片，为了抵消nstimer停止后任然有一定时间运行而导致的图片位移
    self.downloadBGImgView = [[UIImageView alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/15 - LEFT_EDGE, _titleLable.frame.origin.y + SELF_WIDTH/30, SELF_WIDTH/15, SELF_WIDTH/15)];
    _downloadBGImgView.clipsToBounds = YES;
    _downloadBGImgView.layer.cornerRadius = _downloadingImgView.frame.size.width/2;
    _downloadBGImgView.userInteractionEnabled = NO;
    _downloadBGImgView.backgroundColor = [UIColor clearColor];
    
    //下载按钮
    self.downloadBT = [[UIButton alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/15 - LEFT_EDGE, _titleLable.frame.origin.y + SELF_WIDTH/30, SELF_WIDTH/15, SELF_WIDTH/15)];
    _downloadBT.center = CGPointMake(_downloadBT.center.x, SELF_WIDTH*1.0/12);
    _downloadBT.clipsToBounds = YES;
    _downloadBT.layer.cornerRadius = _downloadBT.frame.size.width/2;
    [_downloadBT addTarget:self action:@selector(downloadData:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.downloadBT addSubview:_downloadingImgView];
    [self.contentView addSubview:_downloadBT];
    [self.contentView addSubview:_downloadBGImgView];
    [self.contentView addSubview:_downloadingImgView];
    
}

-(void)downloadData:(UIButton*)button
{
    if (self.downloadDataBlock) {
        _downloadDataBlock();
    }
}

//设置下载按钮图片
-(void)setupDownloadBTImageWithState:(DownloadState)state
{
    switch (state) {
        case DownloadAvilable:
            _downloadBGImgView.image = [[UIImage imageNamed:@"xiazai"] imageWithColor:[UIColor colorWithRed:196.0/255 green:196.0/255 blue:196.0/255 alpha:1]];
            _downloadBGImgView.alpha = 1;
            _downloadingImgView.alpha = 0;
            _downloadBT.userInteractionEnabled = YES;
            
            [self removeDownloadingAnimate];
            break;
        case DownloadPause:
            _downloadingImgView.image = [[UIImage imageNamed:@"zanting-1"] imageWithColor:[UIColor colorWithRed:196.0/255 green:196.0/255 blue:196.0/255 alpha:1]];
            _downloadBGImgView.alpha = 1;
            _downloadingImgView.alpha = 0;
            _downloadBT.userInteractionEnabled = YES;
            
            [self removeDownloadingAnimate];
            break;
        case Downloading:
            _downloadBT.userInteractionEnabled = YES;
            _downloadingImgView.image = [[UIImage imageNamed:@"xiazaizhong"] imageWithColor:[UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
            _downloadBGImgView.alpha = 0;
            _downloadingImgView.alpha = 1;
            [self downloadingAnimate];
            break;
        case DownloadDone:
            _downloadBGImgView.image = [[UIImage imageNamed:@"wancheng"] imageWithColor:[UIColor colorWithRed:50.0/255 green:205.0/255 blue:50.0/255 alpha:0.8]];
            _downloadBGImgView.alpha = 1;
            _downloadingImgView.alpha = 0;
            _downloadBT.userInteractionEnabled = NO;
            
            [self removeDownloadingAnimate];
            break;
        default:
            break;
    }
}

//下载进行中动画
-(void)downloadingAnimate
{
    _downloadingImgView.transform = CGAffineTransformIdentity;
    if (_dl_ingTimer) {
        [_dl_ingTimer invalidate];
        _dl_ingTimer  = nil;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            _dl_ingTimer = [[NSTimer alloc]initWithFireDate:[NSDate date] interval:0.004 target:self selector:@selector(roateDownloading) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_dl_ingTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
        }
    });
}

-(void)roateDownloading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _downloadingImgView.transform = CGAffineTransformRotate(_downloadingImgView.transform, M_PI/360);
    });
}

-(void)removeDownloadingAnimate
{
    if (_dl_ingTimer) {
        [_dl_ingTimer invalidate];
        _dl_ingTimer = nil;
    }
//    _downloadingImgView.transform = CGAffineTransformIdentity;
}

//恢复cell视图
-(void)resumeTitlText
{
    [UIView animateWithDuration:0.2 animations:^{
        //恢复文本颜色
        self.titleLable.textColor = [UIColor blackColor];
        self.titleLable.font = [UIFont boldSystemFontOfSize:16];
        self.timeLable.textColor = [UIColor blackColor];
        self.timeLable.font = [UIFont boldSystemFontOfSize:12];
        
        //恢复文本位置
        self.titleLable.frame = CGRectMake(LEFT_EDGE, SELF_WIDTH/80, SELF_WIDTH*4/5, SELF_WIDTH/10);
        self.timeLable.frame = CGRectMake(LEFT_EDGE, _titleLable.frame.size.height, SELF_WIDTH/3, SELF_WIDTH/30);
    }];
}

-(void)resumeTitlTextRightNow
{
    //恢复文本颜色
    self.titleLable.textColor = [UIColor blackColor];
    self.titleLable.font = [UIFont boldSystemFontOfSize:16];
    self.timeLable.textColor = [UIColor blackColor];
    self.timeLable.font = [UIFont boldSystemFontOfSize:12];
    
    //恢复文本位置
    self.titleLable.frame = CGRectMake(LEFT_EDGE, SELF_WIDTH/80, SELF_WIDTH*4/5, SELF_WIDTH/10);
    self.timeLable.frame = CGRectMake(LEFT_EDGE, _titleLable.frame.size.height, SELF_WIDTH/3, SELF_WIDTH/30);
}

//重建动画
-(void)showTitleText
{
    [UIView animateWithDuration:0.2 animations:^{
        //改变文字颜色
        self.titleLable.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        self.titleLable.font = [UIFont boldSystemFontOfSize:17];
        self.timeLable.textColor = [UIColor colorWithRed:205.0/255 green:38.0/255 blue:38.0/255 alpha:1];
        self.timeLable.font = [UIFont boldSystemFontOfSize:13];
        
        //改变文本位置
        self.titleLable.frame = CGRectMake(LEFT_EDGE + self.downloadBT.frame.size.width + 8, self.titleLable.frame.origin.y, self.titleLable.frame.size.width - self.downloadBT.frame.size.width -8, self.titleLable.frame.size.height);
        self.timeLable.frame = CGRectMake(LEFT_EDGE + self.downloadBT.frame.size.width + 8, self.timeLable.frame.origin.y, self.timeLable.frame.size.width, self.timeLable.frame.size.height);
    }];
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
