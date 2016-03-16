//
//  CellDiskView.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CellDiskView.h"

#define SELF_WIDE  self.frame.size.width
#define SELF_HEIGHT self.frame.size.height

@interface CellDiskView()

@property (nonatomic,strong) UIImageView * headImgView;
@property (nonatomic,strong) UILabel * nameLable;
@property (nonatomic,strong) UILabel * desc_titleLable;
@property (nonatomic,strong) UILabel * playCountLable;
@property (nonatomic,strong) UIImage * diskImage;

@end

@implementation CellDiskView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        
        [self p_setupViewsWithFrame:frame];
    }
    return self;
}

-(void)p_setupViewsWithFrame:(CGRect)frame
{
    //创建button添加点击事件
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self addSubview:button];
    [button addTarget:self action:@selector(didClickPlayAndChangeToList:) forControlEvents:UIControlEventTouchUpInside];
    
    //创建展示图片
    self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDE, SELF_WIDE)];
    _headImgView.backgroundColor = [UIColor whiteColor];
    _headImgView.layer.cornerRadius = _headImgView.frame.size.width/2;
    _headImgView.clipsToBounds = YES;
    _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_headImgView];
    
    //创建播放按钮视图
    UIImageView * btImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _headImgView.frame.size.width*4/9, _headImgView.frame.size.width*4/9)];
    btImgView.center = _headImgView.center;
    btImgView.image = [UIImage imageNamed:@"fmplay"];
    [_headImgView addSubview:btImgView];
    
    //创建标题视图
    self.nameLable = [[UILabel alloc]initWithFrame:CGRectMake(0, _headImgView.frame.origin.y + _headImgView.frame.size.height+ SELF_HEIGHT/20, _headImgView.frame.size.width, SELF_HEIGHT/12)];
    _nameLable.textAlignment = NSTextAlignmentCenter;
    _nameLable.font = [UIFont boldSystemFontOfSize:14];
    _nameLable.text = @"";
    
    [self addSubview:_nameLable];
    
    //创建内容描述视图
    self.desc_titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, _nameLable.frame.origin.y + _nameLable.frame.size.height + SELF_WIDE/30, _headImgView.frame.size.width, SELF_HEIGHT/5)];
    _desc_titleLable.numberOfLines = 2;
    _desc_titleLable.font = [UIFont systemFontOfSize:13];
    _desc_titleLable.text = @"";
    
    [self addSubview:_desc_titleLable];
    
    //创建播放次数图标
    UIImageView * playImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _desc_titleLable.frame.origin.y + _desc_titleLable.frame.size.height + SELF_HEIGHT/40, SELF_WIDE/6, SELF_WIDE/6 )];
    playImgView.image = [UIImage imageNamed:LISTENCOUNT_ICON];
    playImgView.clipsToBounds = YES;
    [self addSubview:playImgView];
    
    
    self.playCountLable = [[UILabel alloc]initWithFrame:CGRectMake(playImgView.frame.origin.x + SELF_HEIGHT/18 + SELF_WIDE/18, playImgView.frame.origin.y, SELF_HEIGHT/3, playImgView.frame.size.height)];
    _playCountLable.textAlignment = NSTextAlignmentLeft;
    _playCountLable.font = [UIFont systemFontOfSize:12];
    _playCountLable.text = @"";
    
    [self addSubview:_playCountLable];
    
    
}

//重写setter方法
-(void)setModel:(FMSubModel *)model
{
    if (_model != model) {
        _model = model;
        
        [_headImgView sd_setImageWithURL:[NSURL URLWithString:_model.imgsrc] placeholderImage:[UIImage imageNamed:HODER_IMG] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                self.diskImage = image;
            }
        }];
        
        _nameLable.text = _model.tname;
        _desc_titleLable.text = _model.title;
        _playCountLable.text = [NSString stringWithFormat:@"%d",_model.playCount];
    }
}

-(void)didClickPlayAndChangeToList:(UIButton*)button
{
    //单例代理执行播放电台功能
    [[ShareManger defoutManger].playDelegate playFMAudioWithaDocid:_model.docid tname:_model.tname andImage:_diskImage];
}


@end
