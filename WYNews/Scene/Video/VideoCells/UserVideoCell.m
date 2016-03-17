//
//  UserVideoCell.m
//  StarProject
//
//  Created by Roy lee on 15/12/23.
//  Copyright © 2015年 xmrk. All rights reserved.
//

#import "UserVideoCell.h"
#import "UITapImageView.h"
#import "NSString+Common.h"
#import "Masonry.h"

#define kTitleDefaultFont       [UIFont systemFontOfSize:17]
#define kContentDefaultFont     [UIFont systemFontOfSize:15]
#define kBottomBarTitleFont     [UIFont systemFontOfSize:12]
// replay button
#define kReplayImageTopMargin   9
#define kReplayImageRightMargin kReplayImageTopMargin
#define kReplayImageTitleInset  3
#define kReplayTitleLeftPadding kReplayImageRightMargin

NSString *const kUserVideoCellIdfy_Normal = @"kUserVideoCellIdfy_Normal";
NSString *const kUserVideoCellIdfy_OtherStyle = @"kUserVideoCellIdfy_OtherStyle";

typedef void(^TapActionBlock)(id sender);
typedef void(^BottomBarTapAction)(id sender,NSInteger index);



#pragma mark ------------------- UserVideoTitleView 个人信息头
@interface UserVideoTitleView ()

@property (nonatomic, strong) UILabel * titleLable;
@property (nonatomic, strong) UILabel * contentLable;

@end

@implementation UserVideoTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height == 0 || frame.size.width == 0) {
        frame.size.width = kScreenWidth;
    }
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setupViews];
    return self;
}

- (void)setupViews
{
    // title
    self.titleLable = ({
        UILabel * title = [UILabel new];
        title.width = self.width - 2 *kVideoLeftPadding;
        title.textColor = [UIColor blackColor];
        title.font = kTitleDefaultFont;
        title.textAlignment = NSTextAlignmentLeft;
        title.left = kVideoLeftPadding;
        [self addSubview:title];
        title;
    });
    self.contentLable = ({
        UILabel * content = [UILabel new];
        content.width = self.width - 2 *kVideoLeftPadding;
        content.textColor = [UIColor colorWithHex:@"999999"];
        content.font = kContentDefaultFont;
        content.textAlignment = NSTextAlignmentLeft;
        content.left = kVideoLeftPadding;
        [self addSubview:content];
        content;
    });
}

// 数据加载
- (void)configTitleBy:(MVideo *)video
{
    // data
    _titleLable.text = video.title;
    _contentLable.text = video.content;
    // layout
    _titleLable.height = video.titleHeight;
    _contentLable.top = _titleLable.bottom;
    _contentLable.height = video.contentHeight;
}


@end








#pragma mark ---------------------- UserVideoBottomBar 底部菜单
@interface BottomBarDisplayItem : UIView

@property (nonatomic, strong) UILabel * titleLable;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIImage * icon;


@end

@implementation BottomBarDisplayItem

- (instancetype)initWithFrame:(CGRect)frame
{
    // 由于布局的简单，这里就写死数据
    if (frame.size.height == 0 || frame.size.width == 0) {
        frame.size = CGSizeMake(80, 20);
    }
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self setupViews];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage*)icon
{
    // 由于布局的简单，这里就写死数据
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(65, 15);
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.title = title;
    self.icon = icon;
    [self setupViews];
    return self;
}

- (void)setupViews
{
    // icon
    UIImageView * iconImgV = [[UIImageView alloc]initWithImage:_icon];
    iconImgV.userInteractionEnabled = YES;
    // title
    self.titleLable = [[UILabel alloc]init];
    _titleLable.font = kBottomBarTitleFont;
    _titleLable.textColor = [UIColor colorWithHex:@"999999"];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.text = _title;
    
    [self addSubview:iconImgV];
    [self addSubview:_titleLable];
    
    // layout
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(self.height, self.height));
    }];
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(iconImgV.mas_right).offset(3);
        make.height.mas_equalTo(self.height);
        make.width.mas_greaterThanOrEqualTo(10);
    }];
    
}

- (void)setupDisplayTitle:(NSString *)title
{
    _titleLable.text = title;
}

@end


// 简单的用了自定义button
@interface BottomBarActionItem  : UIButton

@property (nonatomic, assign) BOOL isTitleImageType;

@end

@implementation BottomBarActionItem

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (_isTitleImageType) {
        CGFloat height = contentRect.size.height - kReplayImageRightMargin * 2;
        titleRect = CGRectMake(kReplayTitleLeftPadding, (contentRect.size.height - height)/2, titleRect.size.width, height);
    }
    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    // image 在假设没有文字是正方矩形的基础上处理rect
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    if (_isTitleImageType) {
        CGFloat width = contentRect.size.height - kReplayImageRightMargin * 2;
        CGFloat height = width;
        imageRect = CGRectMake(contentRect.size.width - width - kReplayImageRightMargin, (contentRect.size.height - height)/2, width, height);
    }
    return imageRect;
}

@end

@interface UserVideoBottomBar ()

@property (nonatomic, strong) BottomBarDisplayItem * playLengthItem;
@property (nonatomic, strong) BottomBarDisplayItem * playCountItem;
@property (nonatomic, strong) BottomBarActionItem * replayItem;
@property (nonatomic, strong) BottomBarActionItem * shareItem;
@property (nonatomic, copy) BottomBarTapAction bottomTapAction;

@end

@implementation UserVideoBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height == 0 || frame.size.width == 0) {
        frame.size.height = kBottomToolbarHeight;
        frame.size.width = kScreenWidth;
    }
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setupViews];
    return self;
}

- (void)setupViews
{
    // play length
    self.playLengthItem = ({
        BottomBarDisplayItem * item = [[BottomBarDisplayItem alloc] initWithTitle:@"00:00" icon:[UIImage imageNamed:@"video_list_cell_time"]];
        item.left = kPaddingLeftWidth;
        item.centerY = self.height/2;
        [self addSubview:item];
        item;
    });
    // play count
    self.playCountItem = ({
        BottomBarDisplayItem * item = [[BottomBarDisplayItem alloc] initWithTitle:@"1000" icon:[UIImage imageNamed:@"video_list_cell_count"]];
        item.left = _playLengthItem.right + 10;
        item.centerY = self.height/2;
        [self addSubview:item];
        item;
    });
    // share itm
    CGFloat itemTopMargin = 11.0f;
    self.shareItem = ({
        BottomBarActionItem * item = [BottomBarActionItem buttonWithType:UIButtonTypeCustom];
        item.size = CGSizeMake(self.height - 2 * itemTopMargin, self.height - 2 * itemTopMargin);
        item.right = kScreenWidth - kVideoLeftPadding;
        item.centerY = self.height/2;
        [item setBackgroundImage:[UIImage imageNamed:@"video_category_share"] forState:UIControlStateNormal];
        [self addSubview:item];
        item;
    });
    self.replayItem = ({
        BottomBarActionItem * item = [BottomBarActionItem buttonWithType:UIButtonTypeCustom];
        item.isTitleImageType = YES;
        item.size = CGSizeMake(self.height - 2 * itemTopMargin, self.height - 2 * itemTopMargin);
        item.right = _shareItem.left - 15;
        item.centerY = self.height/2;
        item.titleLabel.font = kBottomBarTitleFont;
        [item setTitleColor:[UIColor colorWithHex:@"999999"] forState:UIControlStateNormal];
        UIImage * bgImage = [UIImage imageNamed:@"video_comment_bg"];
        CGFloat onepix = 1.0/kScreenScale;
        CGFloat imageW = bgImage.size.width;
        UIEdgeInsets insets = UIEdgeInsetsMake(onepix, (imageW - onepix)/2, onepix, (imageW - onepix)/2);
        bgImage = [bgImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        [item setBackgroundImage:bgImage forState:UIControlStateNormal];
        [item setImage:[UIImage imageNamed:@"video_comment_pen"] forState:UIControlStateNormal];
        [self addSubview:item];
        item;
    });
    // actions
    @weakify(self);
    [self.replayItem addAction:^(id sender) {
        @strongify(self);
        if (self.bottomTapAction) {
            self.bottomTapAction(self,0);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.shareItem addAction:^(id sender) {
        @strongify(self);
        if (self.bottomTapAction) {
            self.bottomTapAction(self,1);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)refresTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0) {
        [_playLengthItem setupDisplayTitle:title];
    }else if (index == 1) {
        [_playCountItem setupDisplayTitle:title];
    }else if (index == 2) {
        [_replayItem setTitle:title forState:UIControlStateNormal];
    }
}



- (void)configBottomBarBy:(MVideo *)video
{
    // time length
    NSString * length = [NSDate formattedPlayTimeFromTimeInterval:video.length];
    [_playLengthItem setupDisplayTitle:length];
    // play times
    NSString * playCount = [NSString formatterNumberString:video.playCount];
    [_playCountItem setupDisplayTitle:playCount];
    // replay count
    CGFloat titleImageInset = 0;
    NSString * replayCount = [NSString stringWithFormat:@"%ld",video.replyCount];
    if (video.replyCount == 0) {
        replayCount = @"";
    }else {
        titleImageInset = kReplayImageTitleInset;
    }
    [_replayItem setTitle:replayCount forState:UIControlStateNormal];
    
    // layout replay item
    CGFloat imageWidth = _replayItem.height - 2 * kReplayImageTopMargin;
    CGFloat titleHeight = imageWidth;    // title height = image width
    CGFloat titleWidth = [replayCount getWidthWithFont:kBottomBarTitleFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, titleHeight)];
    _replayItem.width = (kReplayTitleLeftPadding + kReplayImageRightMargin) + (titleWidth + titleImageInset + imageWidth);
    _replayItem.right = _shareItem.left - 15;
}

@end





#pragma mark ---------------------- UserVideoCell    cell
@interface UserVideoCell ()

@property (nonatomic, strong) UIView * containerView;
@property (nonatomic, strong) MVideo * video;

@end

@implementation UserVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor colorWithHex:@"f2f2f2"];
    [self setupViews];
    [self initAction];
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor colorWithHex:@"f2f2f2"];
    [self setupViews];
    [self initAction];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (![self.containerView viewWithTag:kTagLineViewUp]) {
        // line
        [self.containerView addLineUp:YES andDown:YES andColor:[UIColor colorWithHex:@"dddddd"] andLeftSpace:0 rightSpace:0];
    }
}

- (void)setupViews
{
    // bg content
    self.containerView = [UIView new];
    _containerView.width = kScreenWidth;
    _containerView.backgroundColor = [UIColor whiteColor];
    
    // title
    self.titleView = [[UserVideoTitleView alloc]init];
    _titleView.backgroundColor = [UIColor whiteColor];
    
    // play view
    self.playView = [[VideoPlayView alloc]init];
    _playView.backgroundColor = [UIColor blackColor];
    
    // bottom bar
    self.bottomBar = [UserVideoBottomBar new];
    _bottomBar.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:_containerView];
    [_containerView addSubview:_titleView];
    [_containerView addSubview:_playView];
    [_containerView addSubview:_bottomBar];
    // layout views
    _titleView.width = kScreenWidth;
    _playView.left = kVideoLeftPadding;
    _playView.width = kScreenWidth - kVideoLeftPadding * 2;
    _bottomBar.width = kScreenWidth;
}

- (void)initAction
{
    // play view
    @weakify(self)
    _playView.playVideoAction = ^(UIButton * button){
        @strongify(self)
        if (_delegate && [_delegate respondsToSelector:@selector(userVideoCell:startPlay:)]) {
            [self.delegate userVideoCell:self startPlay:self.video];
        }
    };
    _playView.playPauseAction = ^(UITapImageView *imgView){
        @strongify(self)
        if (_delegate && [_delegate respondsToSelector:@selector(userVideoCell:playPuse:)]) {
            [self.delegate userVideoCell:self playPuse:self.video];
        }
    };
    _playView.fullScreenAction = ^(UIButton * button){
        @strongify(self)
        if (_delegate && [_delegate respondsToSelector:@selector(userVideoCell:fullScreenBt:)]) {
            [self.delegate userVideoCell:self fullScreenBt:button];
        }
    };
    _playView.changeProgressAction = ^(UISlider * slider){
        @strongify(self)
        if (_delegate && [_delegate respondsToSelector:@selector(userVideoCell:changePlayProgress:)]) {
            [self.delegate userVideoCell:self changePlayProgress:slider.value];
        }
    };
    
    // bottom bar
    _bottomBar.bottomTapAction = ^(UIButton * bt,NSInteger index){
        @strongify(self)
        if (self.delegate && [self.delegate respondsToSelector:@selector(userVideoCell:toolBarClickedAtIndex:)]) {
            [self.delegate userVideoCell:self toolBarClickedAtIndex:index];
        }
    };
}

// 配置cell数据
- (void)configCellWith:(MVideo *)video
{
    if (nil == video) {
        return;
    }
    NSLog(@"视频model是：%@",video);
    self.video = video;
    // title
    [_titleView configTitleBy:video];
    // video
    [_playView configPlayViewBy:video];
    // bottom bar
    [_bottomBar configBottomBarBy:video];
    
    // layout subviews
    _titleView.top = video.titleTop;
    _titleView.height = video.titleHeight + video.contentHeight;
    
    _playView.top = video.videoTop;
    _playView.height = video.videoHeight;
    
    _bottomBar.top = _playView.bottom;
    _bottomBar.height = video.bottomBarHeight;
    
    _containerView.top = video.marginTop;
    _containerView.height = video.containerHeight;
}

- (void)refreshPlayViewBy:(MVideo *)video isOnlyProgress:(BOOL)isProgress
{
    if (isProgress) {
        [_playView refreshProgress:video.statusLayout];
    }else {
        [_playView configPlayViewBy:video];
    }
}

+ (CGFloat)cellHeightWith:(MVideo *)video
{
    return video.cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
