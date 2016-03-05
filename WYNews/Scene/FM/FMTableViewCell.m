//
//  FMTableViewCell.m
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "FMTableViewCell.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.width*2/3

@interface FMTableViewCell()

{
    CellDiskView * _diskView_1;
    CellDiskView * _diskView_2;
    CellDiskView * _diskView_3;
}
@property (nonatomic,strong) UIImageView * headImgView;
@property (nonatomic,strong) UIImageView * enterImgView;
@property (nonatomic,strong) UILabel * titlLable;
@property (nonatomic,strong) UIButton * enterButton;
@property (nonatomic,strong) UIView * bgView;

@end

@implementation FMTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self p_setupViews];
        
        [self p_setupDiskView];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1];
    }
    return self;
}

-(void)p_setupViews
{
    //创建背景图
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, SELF_WIDTH*0.5/30, SELF_WIDTH, SELF_HEIGHT*29.3/30)];
    _bgView.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:250.0/255 alpha:1];
    _bgView.layer.borderWidth = 0.3;
    _bgView.layer.borderColor = [[UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1]CGColor];
    
    [self.contentView addSubview:_bgView];
    
    //创建导航标题视图
    self.enterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SELF_WIDTH, SELF_HEIGHT/8)];
    [_enterButton addTarget:self action:@selector(didClickEnter) forControlEvents:UIControlEventTouchUpInside];
    _enterButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:240.0/255 alpha:1];
    //    _enterButton.alpha = 0;
    _enterButton.layer.borderColor = [[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1]CGColor];
    _enterButton.layer.borderWidth = 0.5;
    
    [_bgView addSubview:_enterButton];
    
    //创建标题头像图
    self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(SELF_HEIGHT/25, SELF_HEIGHT/50, SELF_HEIGHT*3.6/40, SELF_HEIGHT*3.6/40)];
    _headImgView.backgroundColor = [UIColor grayColor];
    _headImgView.center = CGPointMake(_headImgView.center.x, _enterButton.center.y);
    _headImgView.layer.cornerRadius = _headImgView.frame.size.width/2;
    
    [_bgView addSubview:_headImgView];
    
    //创建标题lable
    self.titlLable = [[UILabel alloc]initWithFrame:CGRectMake(_headImgView.frame.origin.x + LEFT_EDGE, 0, SELF_WIDTH/3, SELF_WIDTH/20)];
    _titlLable.font = [UIFont systemFontOfSize:14];
    _titlLable.center = CGPointMake(_headImgView.frame.origin.x + SELF_WIDTH/4, _enterButton.center.y);
    _titlLable.textAlignment = NSTextAlignmentLeft;
    
    [_bgView addSubview:_titlLable];
    
    //创建“进入”lable
    UILabel * enterLable = [[UILabel alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/4, _titlLable.frame.origin.y, SELF_WIDTH/8, _titlLable.frame.size.height)];
    enterLable.textAlignment = NSTextAlignmentRight;
    enterLable.tintColor = [UIColor lightGrayColor];
    enterLable.text = @"进入";
    enterLable.font = [UIFont systemFontOfSize:14];
    
    [_bgView addSubview:enterLable];
    
    //创建点击指示按钮图片
    UIImageView * enterImgView = [[UIImageView alloc]initWithFrame:CGRectMake(SELF_WIDTH - SELF_WIDTH/25 - enterLable.frame.size.height, enterLable.frame.origin.y, enterLable.frame.size.height, enterLable.frame.size.height)];
    enterImgView.backgroundColor = [UIColor clearColor];
    enterImgView.image = [UIImage imageNamed:ENTER_ICON];
    
    [_bgView addSubview:enterImgView];
    
}

//通过下标设置标题图片
-(void)setupImageForTitleAtindex:(NSInteger)index
{
    switch (index) {
        case 0:
            _headImgView.image = [UIImage imageNamed:@"yuanchuang"];
            break;
        case 1:
            _headImgView.image = [UIImage imageNamed:@"zixun"];
            break;
        case 2:
            _headImgView.image = [UIImage imageNamed:@"gaoxiao"];
            break;
        case 3:
            _headImgView.image = [UIImage imageNamed:@"caijing"];
            break;
        case 4:
            _headImgView.image = [UIImage imageNamed:@"yule"];
            break;
        case 5:
            _headImgView.image = [UIImage imageNamed:@"tiyu"];
            break;
        case 6:
            _headImgView.image = [UIImage imageNamed:@"qinggan"];
            break;
        case 7:
            _headImgView.image = [UIImage imageNamed:@"yinyue"];
            break;
        default:
            break;
    }
}

//添加音乐视图
-(void)p_setupDiskView
{
    _diskView_1 = [[CellDiskView alloc]initWithFrame:CGRectMake(SELF_HEIGHT/25, _enterButton.frame.size.height + SELF_HEIGHT/25,(SELF_WIDTH*22/25)*1.0/3,SELF_WIDTH/2)];
    _diskView_2 = [[CellDiskView alloc]initWithFrame:CGRectMake(_diskView_1.frame.size.width + 2*SELF_HEIGHT/25, _diskView_1.frame.origin.y, _diskView_1.frame.size.width, _diskView_1.frame.size.height)];
    _diskView_3 = [[CellDiskView alloc]initWithFrame:CGRectMake(_diskView_1.frame.size.width*2+ 3*SELF_HEIGHT/25, _diskView_1.frame.origin.y, _diskView_1.frame.size.width, _diskView_1.frame.size.height)];
    
    [self.bgView addSubview:_diskView_1];
    [self.bgView addSubview:_diskView_2];
    [self.bgView addSubview:_diskView_3];
}

//重写setter方法
-(void)setFm_model:(FMModel *)fm_model
{
    if (_fm_model != fm_model) {
        _fm_model = fm_model;
        
        self.titlLable.text = _fm_model.cname;
        
        _diskView_1.model = (FMSubModel*)_fm_model.subModelArray[0];
        _diskView_2.model = (FMSubModel*)_fm_model.subModelArray[1];
        _diskView_3.model = (FMSubModel*)_fm_model.subModelArray[2];
    }
}

//点击进入事件
-(void)didClickEnter
{
    if (_enterBlock) {
        _enterBlock(_fm_model.cid);
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
