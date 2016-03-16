//
//  VideoSortHeaderBar.m
//  WYNews
//
//  Created by Roy lee on 16/3/16.
//  Copyright © 2016年 lanou3g. All rights reserved.
//

#import "VideoSortHeaderBar.h"

#define kItemTitleFont          [UIFont systemFontOfSize:14]
#define kItemIconTitleInsert    8
#define kItemTitleHeight        kScaleFrom_iPhone5_Desgin(15)


@interface SortBarHeaderItem : UIView

@property (nonatomic, strong) UILabel * titleLable;
@property (nonatomic, strong) UIImageView * iconImgV;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * iconUrl;
@property (nonatomic, copy) void(^tapAction)(id sender);

@end

@implementation SortBarHeaderItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title icon:(NSString*)iconUrl
{
    self = [super initWithFrame:CGRectZero];
    if (!self) {
        return nil;
    }
    self.title = title;
    self.iconUrl = iconUrl;
    [self setupViews];
    return self;
}

- (void)layoutSubviews
{
    self.iconImgV.layer.cornerRadius = self.iconImgV.width/2;
}

- (void)setupViews
{
    // content center view
    UIView * contentView = [UIView new];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    // icon
    self.iconImgV = [[UIImageView alloc]init];
    _iconImgV.userInteractionEnabled = YES;
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.layer.drawsAsynchronously = YES;
    _iconImgV.layer.shouldRasterize = YES;
    _iconImgV.layer.rasterizationScale = kScreenScale;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_iconUrl]];
    // title
    self.titleLable = [[UILabel alloc]init];
    _titleLable.font = kItemTitleFont;
    _titleLable.textColor = [UIColor colorWithHex:@"999999"];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.text = _title;
    
    [contentView addSubview:_iconImgV];
    [contentView addSubview:_titleLable];
    
    // bt
    UIButton * bt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:bt];
    
    // layout
    [bt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [_iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.width.mas_equalTo(self.mas_width).multipliedBy(1.2/3);
        make.height.mas_equalTo(_iconImgV.mas_width);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconImgV.mas_bottom).offset(kItemIconTitleInsert);
        make.height.mas_equalTo(kItemTitleHeight);
        make.centerX.mas_equalTo(_iconImgV);
        make.width.mas_greaterThanOrEqualTo(10);
        make.bottom.mas_equalTo(0);
    }];
    // action
    @weakify(self);
    [bt addAction:^(id sender) {
        @strongify(self);
        if (self.tapAction) {
            self.tapAction(self);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title icon:(NSString *)iconUrl
{
    _titleLable.text = title;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:iconUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
}

@end





@interface VideoSortHeaderBar ()

@property (nonatomic, copy) void(^itemClickedAction)(id item,NSInteger index);

@end

@implementation VideoSortHeaderBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height == 0 || frame.size.width == 0) {
        frame.size.width = kScreenWidth;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupViews];
    }
    return self;
}

+ (VideoSortHeaderBar *)sortHeaderBar
{
    VideoSortHeaderBar * bar = [[VideoSortHeaderBar alloc]init];
    return bar;
}

- (void)setupViews
{
    if (_sorts.count <= 0) {
        self.height = 0;
        self.hidden = YES;
        return;
    }
    // remove old views
    for (UIView * subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat lineW = 1.0/kScreenScale;
    CGFloat itemH = kScreenWidth/_sorts.count;
    NSInteger items = _sorts.count;
    for (int i = 0; i < _sorts.count; i ++) {
        MVideoSort * sort = _sorts[i];
        SortBarHeaderItem * item = [[SortBarHeaderItem alloc]initWithTitle:sort.title icon:sort.imageUrl];
        item.tag = 1000 + i;
        [self addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.mas_equalTo(0);
            }else {
                UIView * forwardLine = [self viewWithTag:499 + i];
                make.left.mas_equalTo(forwardLine.mas_right);
            }
            make.width.mas_equalTo(self).multipliedBy(1.0/items).offset((lineW * (items - 1))/items);
            make.height.mas_equalTo(itemH);
            make.centerY.mas_equalTo(self);
        }];
        // line
        if (i < items - 1) {
            UIView * line = [[UIView alloc]init];
            line.backgroundColor = [UIColor colorWithHex:@"e6e6e6"];
            line.tag = 500 + i;
            [self addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(item.mas_right).offset(lineW);
                make.top.mas_equalTo(0);
                make.centerY.mas_equalTo(self);
                make.width.mas_equalTo(lineW);
            }];
        }
        // action
        @weakify(self);
        [item setTapAction:^(id sender) {
            @strongify(self);
            if (self.headerSortBarDidSelectedItemBlock) {
                self.headerSortBarDidSelectedItemBlock(self.sorts[i],i);
            }
        }];
    }
    self.height = itemH;
    self.hidden = NO;
    // line
    [self addLineUp:NO andDown:YES andColor:[UIColor colorWithHex:@"dddddd"] andLeftSpace:0 rightSpace:0];
}

- (void)setSorts:(NSArray *)sorts
{
    if (nil != sorts) {
        // 重置UI
        if (_sorts.count != sorts.count) {
            _sorts = sorts;
            [self setupViews];
        }
        // 刷新数据
        else {
            _sorts = sorts;
            for (int i = 0; i < _sorts.count; i ++) {
                MVideoSort * sort = _sorts[i];
                SortBarHeaderItem * item = [self viewWithTag:1000 + i];
                [item setTitle:sort.title icon:sort.imageUrl];
            }
        }
    }
}

@end

