//
//  FMCateListTableViewCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMCateListTableViewCell.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height

@interface FMCateListTableViewCell()

@property (nonatomic,strong) UILabel * titleLable;
@property (nonatomic,strong) UILabel * descLable;
@property (nonatomic,strong) UILabel * playCountLable;
@property (nonatomic,strong) UIImageView * playCountIV;

@end

@implementation FMCateListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self p_setupViews];
        
    self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:240.0/255 alpha:1];
    }
    return self;
}

-(void)p_setupViews
{
    //创建标题视图
    self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_EDGE, SELF_WIDTH/50, SELF_WIDTH*5.7/27, SELF_WIDTH*5.7/27)];
    _headImgView.clipsToBounds = YES;
    _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    _headImgView.layer.cornerRadius = _headImgView.frame.size.width/2;
    _headImgView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * playImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _headImgView.frame.size.width*4/9, _headImgView.frame.size.width*4/9)];
    playImgView.image = [UIImage imageNamed:@"play_1"];
    playImgView.layer.cornerRadius = playImgView.frame.size.width/2;
    playImgView.clipsToBounds = YES;
    playImgView.contentMode = UIViewContentModeScaleAspectFill;
    playImgView.center = CGPointMake(_headImgView.frame.size.width/2, _headImgView.frame.size.width/2);
    
    [_headImgView addSubview:playImgView];
    
    [self.contentView addSubview:_headImgView];
    
    //创建标题
    self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(_headImgView.frame.size.width + SELF_WIDTH/30 + SELF_WIDTH/30, SELF_WIDTH/20, SELF_WIDTH *29/30 - (_headImgView.frame.size.width + SELF_WIDTH/30), SELF_WIDTH/20)];
    _titleLable.font = [UIFont boldSystemFontOfSize:17];
    _titleLable.text = @"标题暂时为空";
    
    [self.contentView addSubview:_titleLable];
    
    //创建描述
    self.descLable = [[UILabel alloc]initWithFrame:CGRectMake(_titleLable.frame.origin.x, _titleLable.frame.size.height + _titleLable.frame.origin.y + SELF_WIDTH/30, SELF_WIDTH - _titleLable.frame.origin.x - SELF_WIDTH/30, SELF_WIDTH/25)];
    _descLable.font = [UIFont systemFontOfSize:14];
    _descLable.textColor = [UIColor lightGrayColor];
    
    _descLable.text = @"描述内容暂时没有";
    
    [self.contentView addSubview:_descLable];
    
    //创建音乐播放次数图片
    CGFloat playCount_W = [NSString textLableWideth:[NSString stringWithFormat:@"000"] andFont:[UIFont systemFontOfSize:13]];  //动态调整lable的宽度
    
    self.playCountIV = [[UIImageView alloc]initWithFrame:CGRectMake((SELF_WIDTH-LEFT_EDGE) - playCount_W - SELF_WIDTH/30 - SELF_WIDTH/70, _descLable.frame.origin.y + _descLable.frame.size.height + SELF_WIDTH/100, SELF_WIDTH/27, SELF_WIDTH/27)];
    _playCountIV.image = [UIImage imageNamed:LISTENCOUNT_ICON];
    
    [self.contentView addSubview:_playCountIV];
    
    //创建音乐播放次数lable
    self.playCountLable = [[UILabel alloc]initWithFrame:CGRectMake((SELF_WIDTH-LEFT_EDGE) - playCount_W, _playCountIV.frame.origin.y, playCount_W, _playCountIV.frame.size.height)];
    _playCountLable.font = [UIFont systemFontOfSize:13];
    _playCountLable.text = @"000";
    
    [self.contentView addSubview:_playCountLable];
}

//重写setter方法
-(void)setModel:(FMSubModel *)model
{
    if (_model != model) {
        _model = model;
        self.titleLable.text = _model.tname;
        self.descLable.text = _model.title;
        self.playCountLable.text = [NSString stringWithFormat:@"%d",_model.playCount];
        
        //创建音乐播放次数图片
        CGFloat playCount_W = [NSString textLableWideth:[NSString stringWithFormat:@"%d",_model.playCount] andFont:[UIFont systemFontOfSize:13]];  //动态调整lable的宽度
        
        //动态调整播放次数的宽度
        self.playCountIV.frame = CGRectMake((SELF_WIDTH-LEFT_EDGE) - playCount_W - SELF_WIDTH/30 - SELF_WIDTH/70, _descLable.frame.origin.y + _descLable.frame.size.height + SELF_WIDTH/100, SELF_WIDTH/27, SELF_WIDTH/27);
        
        //创建音乐播放次数lable
        self.playCountLable.frame = CGRectMake((SELF_WIDTH-LEFT_EDGE) - playCount_W, _playCountIV.frame.origin.y, playCount_W, _playCountIV.frame.size.height);
        
        
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:_model.imgsrc] placeholderImage:[UIImage imageNamed:HODER_IMG] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
