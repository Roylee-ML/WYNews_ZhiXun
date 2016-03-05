//
//  SCNavTabBar.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBar.h"
#import "CommonMacro.h"
#import "SCPopView.h"


#define NAC_BAR_HEIGHT self.inputViewController.navigationController.navigationBar.frame.size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define ARROW_BT_WIDETH self.frame.size.height

#define SCALE_PER 1.0/6

@interface SCNavTabBar () <SCPopViewDelegate>
{
    UIScrollView    *_navgationTabBar;      // all items on this scroll view
    UIImageView     *_arrowButton;          // arrow button
    
    UIView          *_line;                 // underscore show which item selected
    SCPopView       *_popView;              // when item menu, will show this view
    
    NSMutableArray  *_items;                // SCNavTabBar pressed item
    NSArray         *_itemsWidth;           // an array of items' width
    BOOL            _showArrowButton;       // is showed arrow button
    BOOL            _popItemMenu;           // is needed pop item menu
}

@property (nonatomic,assign) NSInteger clickTag;
@property (nonatomic,assign) NSInteger itemWideth;
@property (nonatomic,strong) NSMutableArray * titleLables;


@end

@implementation SCNavTabBar

- (id)initWithFrame:(CGRect)frame showArrowButton:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = frame;
        _showArrowButton = show;
        [self initConfig];
        
        _popItemMenu = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Private Methods

- (void)initConfig
{
    _items = [@[] mutableCopy];
    _arrowImage = [UIImage imageNamed:SCNavTabbarSourceName(@"arrow.png")];
    
    [self viewConfig];
    [self addTapGestureRecognizer];
    
}

- (void)viewConfig
{
    CGFloat functionButtonX = _showArrowButton ? (SCREEN_WIDTH - self.frame.size.height) : self.frame.size.height;
    if (_showArrowButton)
    {
        _arrowButton = [[UIImageView alloc] initWithFrame:CGRectMake(functionButtonX, DOT_COORDINATE, self.frame.size.height, self.frame.size.height)];
        //        _arrowButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _arrowButton.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1];
        _arrowButton.image = _arrowImage;
        _arrowButton.userInteractionEnabled = YES;
        [self addSubview:_arrowButton];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionButtonPressed)];
        [_arrowButton addGestureRecognizer:tapGestureRecognizer];
    }
    
    //创建滚动栏
    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, functionButtonX, self.frame.size.height)];
    _navgationTabBar.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:_navgationTabBar];
    
    //    [self viewShowShadow:self shadowRadius:10.0f shadowOpacity:10.0f];
}

- (void)showLineWithButtonWidth:(CGFloat)width
{
    _line = [[UIView alloc] initWithFrame:CGRectMake(2.0f, self.frame.size.height - 3.0f, width - 4.0f, 3.0f)];
    _line.backgroundColor = UIColorWithRGBA(193.0f, 205.0f, 193.0f, 0.7f);
    _line.layer.cornerRadius = 1.5;
    [_navgationTabBar addSubview:_line];
}

//根据宽度创建scrollview的button,并返回最大的宽度
- (CGFloat)contentWidthAndAddNavTabBarItemsWithButtonsWidth:(NSArray *)widths
{
    CGFloat buttonX = DOT_COORDINATE;
    _itemWideth = [widths[0] floatValue];
    
    self.titleLables = [@[] mutableCopy];
    
    UILabel * firstLable = [[UILabel alloc]initWithFrame:CGRectMake(buttonX, DOT_COORDINATE, [widths[0] floatValue], self.frame.size.height)];
    firstLable.textAlignment = NSTextAlignmentCenter;
    firstLable.text = _itemTitles[0];
    firstLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
//    firstLable.font = [UIFont fontWithName:TITLE_FONT size:TitleFont_Size];
    firstLable.font = [UIFont systemFontOfSize:TitleFont_Size];
    firstLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
    firstLable.userInteractionEnabled = YES;
    
    [_titleLables addObject:firstLable];
    [_navgationTabBar addSubview:firstLable];
    
    UIButton *firstBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, [widths[0] floatValue], self
                                                                  .frame.size.height)];
    firstBT.backgroundColor = [UIColor clearColor];
    firstBT.tag = 200;
    _clickTag = firstBT.tag;
    [firstBT addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLable addSubview:firstBT];
    
    [_items addObject:firstBT];
    
    buttonX = [widths[0] floatValue];
    
    for (NSInteger index = 1; index < [_itemTitles count]; index++)
    {
#pragma mark ----- 设置字体颜色大小 -----
        
        UILabel * titleLable = [[UILabel alloc]initWithFrame:CGRectMake(buttonX, DOT_COORDINATE, [widths[index] floatValue], self.frame.size.height)];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.text = _itemTitles[index];
        titleLable.textColor = [UIColor blackColor];
//        titleLable.font = [UIFont fontWithName:TITLE_FONT size:TitleFont_Size];
        titleLable.font = [UIFont systemFontOfSize:TitleFont_Size];
        titleLable.userInteractionEnabled = YES;
        
        [_titleLables addObject:titleLable];
        [_navgationTabBar addSubview:titleLable];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, [widths[index] floatValue], self
                                                                     .frame.size.height)];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 200 + index;
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [titleLable addSubview:button];
        
        [_items addObject:button];
        buttonX += [widths[index] floatValue];
    }
    
    [self showLineWithButtonWidth:[widths[0] floatValue]];
    return buttonX;
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionButtonPressed)];
    [_arrowButton addGestureRecognizer:tapGestureRecognizer];
}

//点击标题
- (void)itemPressed:(UIButton *)button
{
    
    NSInteger index = [_items indexOfObject:button];
    
    //改变点击标题按钮的状态
//    [self changeTitleColorWithAtIndex:index];  //先执行方法，以免改写_currentitemindex
    
    //改变scrollview的offset
    [self changeScrollViewOffsetAndColorByClickAtIndex:index];
    
    [_delegate itemDidSelectedWithIndex:index];
    
}

/****///滑动改变字体
-(void)changeTitleColorWithAtIndex:(NSInteger)index
{
    UILabel * oldTitle = (UILabel*)[_titleLables objectAtIndex:_currentItemIndex];
    if (oldTitle) {
        [UIView animateWithDuration:0.5 animations:^{
            oldTitle.textColor = [UIColor blackColor];
            oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        }];
    }
    
    UILabel * newLable = (UILabel*)[_titleLables objectAtIndex:index];
    [UIView animateWithDuration:0.7 animations:^{
        newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
        newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
    }];
}

- (void)functionButtonPressed
{
    _popItemMenu = !_popItemMenu;

    [_delegate shouldPopNavgationItemMenu:_popItemMenu height:[self popMenuHeight]];
}

//获取每个标题文本的宽度
- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles byHeight:(CGFloat)height
{
    NSMutableArray *widths = [@[] mutableCopy];
    
    for (NSString *title in titles)
    {
        CGSize size = CGSizeMake(1000, height);
        
        CGRect rect = [title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TitleFont_Size]} context:nil];
        
        NSNumber *width = [NSNumber numberWithFloat:rect.size.width + 40.0f];
        [widths addObject:width];
    }
    
    return widths;
}

//获取推出动画视图的高度，即_popView的高度
- (CGFloat)popMenuHeight
{
    CGFloat buttonX = DOT_COORDINATE;
//    CGFloat buttonY = self.frame.size.height;
    CGFloat buttonY = self.titleHeight;
    CGFloat maxHeight = SCREEN_HEIGHT - STATUS_HEIGHT - NAC_BAR_HEIGHT - self.frame.size.height;
    for (NSInteger index = 0; index < [_itemsWidth count]; index++)
    {
        buttonX += [_itemsWidth[index] floatValue] - 10;
        
        @try {
            if ((buttonX + [_itemsWidth[index + 1] floatValue]) >= (SCREEN_WIDTH -self.frame.size.height))
            {
                buttonX = DOT_COORDINATE;
                buttonY += self.titleHeight;
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    buttonY = (buttonY > maxHeight) ? maxHeight : buttonY;
    return buttonY;
}

- (void)popItemMenuWith:(BOOL)pop
{
    if (pop)
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navgationTabBar.hidden = YES;
            _arrowButton.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                if (!_popView)
                {
                    _popView = [[SCPopView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, 0, SCREEN_WIDTH , [self popMenuHeight])];
                    _popView.titleHeight = self.titleHeight;
                    _popView.delegate = self;
                    _popView.itemNames = _itemTitles;
                    [self addSubview:_popView];
                    NSLog(@"titleHeight ========= %.2f",self.frame.size.height);
                    
                    //将箭头按钮移到前面，保证点击事件
                    [self bringSubviewToFront:_arrowButton];
                }
                _popView.hidden = NO;
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _popView.hidden = !_popView.hidden;
            _arrowButton.transform = CGAffineTransformRotate(_arrowButton.transform, -M_PI/2);
        } completion:^(BOOL finished) {
            _navgationTabBar.hidden = !_navgationTabBar.hidden;
        }];
    }
}

#pragma mark -
#pragma mark - Public Methods
- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage ? arrowImage : _arrowImage;
    _arrowButton.image = _arrowImage;
}

#pragma mark ---改变offset与lable颜色----
/*
    *为保证UI界面渲染变化的连贯性，将改变字体颜色与改变scrollView的offset放在一个UIView动画里 
*/

//点击标题执行的方法
- (void)changeScrollViewOffsetAndColorByClickAtIndex:(NSInteger)currentItemIndex
{
    
    //改变颜色
    UILabel * oldTitle = (UILabel*)[_titleLables objectAtIndex:_currentItemIndex];
    
    UILabel * newLable = (UILabel*)[_titleLables objectAtIndex:currentItemIndex];
    
    //改变offset
    UIButton *button = _items[currentItemIndex];
    UILabel * titlLable = (UILabel*)[button superview];
    
    CGFloat flag = (SCREEN_WIDTH - [_itemsWidth[0] floatValue])/2;
    
    CGFloat offsetX = titlLable.frame.origin.x  - flag;
    
    if (titlLable.frame.origin.x  > flag)
    {
        if (_arrowButton) {
            
            CGFloat maxOffset = _navgationTabBar.contentSize.width -(SCREEN_WIDTH - self.frame.size.height);
            
            if (offsetX <= maxOffset) {
                [UIView animateWithDuration:0.5f animations:^{
                    //1.改变offset
                    _navgationTabBar.contentOffset = CGPointMake(offsetX, DOT_COORDINATE);
                    
                    //2.改变文本颜色
                    if (oldTitle) {
                        oldTitle.textColor = [UIColor blackColor];
                        oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                    }
                    newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
                    newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
                }];
            }else{
                [UIView animateWithDuration:0.5f animations:^{
                    _navgationTabBar.contentOffset = CGPointMake(maxOffset, DOT_COORDINATE);
                    
                    //2.改变文本颜色
                    if (oldTitle) {
                        oldTitle.textColor = [UIColor blackColor];
                        oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                    }
                    newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
                    newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
                }];
            }
        }else{
            CGFloat maxOffset = (_navgationTabBar.contentSize.width -SCREEN_WIDTH);
            
            if (offsetX <= maxOffset) {
                [UIView animateWithDuration:0.5f animations:^{
                    _navgationTabBar.contentOffset = CGPointMake(offsetX, DOT_COORDINATE);
                    
                    //2.改变文本颜色
                    if (oldTitle) {
                        oldTitle.textColor = [UIColor blackColor];
                        oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                    }
                    newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
                    newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
                }];
            }else{
                [UIView animateWithDuration:0.5f animations:^{
                    _navgationTabBar.contentOffset = CGPointMake(maxOffset, DOT_COORDINATE);
                    
                    //2.改变文本颜色
                    if (oldTitle) {
                        oldTitle.textColor = [UIColor blackColor];
                        oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                    }
                    newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
                    newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
                }];
            }
        }
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            _navgationTabBar.contentOffset = CGPointMake(DOT_COORDINATE, DOT_COORDINATE);
            
            //2.改变文本颜色
            if (oldTitle) {
                oldTitle.textColor = [UIColor blackColor];
                oldTitle.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            }
            newLable.textColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
            newLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1+SCALE_PER, 1+SCALE_PER);
        }];
    }
    
    CGFloat lineOffset = titlLable.frame.origin.x + titlLable.frame.size.width*SCALE_PER/2 +2;
    
    //改变下划线
    [UIView animateWithDuration:0.5f animations:^{
        _line.frame = CGRectMake(lineOffset, _line.frame.origin.y, [_itemsWidth[0] floatValue] - 4.0f, _line.frame.size.height);
    }];
    
    _currentItemIndex = currentItemIndex;
}

#pragma mark ----- 无缝滚动实现 -----

//无缝滚动设置标题栏offset
-(void)setScrollViewOffsetByoffsetPercentage:(CGFloat)offsetPercetage
{
    CGFloat offsetX = _navgationTabBar.contentSize.width * offsetPercetage;
    
    CGFloat flagOffset = (SCREEN_WIDTH - [_itemsWidth[0] floatValue])/2;
    
    CGFloat maxOffset = _navgationTabBar.contentSize.width - (SCREEN_WIDTH - self.frame.size.height);
    
    if (_arrowButton) {
        if (offsetX>flagOffset) {
            
            CGFloat newOffset = offsetX - flagOffset;
            
            if (newOffset <= maxOffset) {
#pragma mark ------- contentOffset的设置方法选择 -------- 
                
/*
     *当在代理协议中执行方法时，由于回调是随时的。不宜用animate的方法。而是采用直接属性改变值的方法。
     *因为对scrollView采用animate的方法，会占用主线程的滚动事件。此时若是用户再作别的scrollView的滚动处理，此时这里的
     *scrollView便会被迫停止。所以采用直接属性改变值得方式，不会占用线程。
*/
                
//                [_navgationTabBar setContentOffset:CGPointMake(newOffset, 0) animated:YES];
                _navgationTabBar.contentOffset = CGPointMake(newOffset, 0);
            }else{
//                [_navgationTabBar setContentOffset:CGPointMake(maxOffset, 0) animated:YES];
                _navgationTabBar.contentOffset = CGPointMake(maxOffset, 0);
            }
        }else{
//            [_navgationTabBar setContentOffset:CGPointMake(0, 0) animated:YES];
            _navgationTabBar.contentOffset = CGPointMake(0, 0);
        }
    }
}

//无缝滚动设置标题栏颜色大小变化
-(void)setCurrentOffsetPercentage:(CGFloat)currentOffsetPercentage
{
    NSInteger offsetX = _navgationTabBar.contentSize.width * currentOffsetPercentage;
    
    CGFloat itemPer = (offsetX%_itemWideth)*1.0/_itemWideth;
    
    //获取当前相邻的两个标题lable
    NSInteger frontIndex = offsetX/_itemWideth;
    NSInteger tailIndex = frontIndex + 1;
    
    if (tailIndex<_items.count) {
        
        UILabel * frontLable = (UILabel*)[_items[frontIndex]superview];
        UILabel * tailLable = (UILabel*)[_items[tailIndex]superview];
        
        frontLable.textColor = [UIColor colorWithRed:(1 - itemPer)*165.0/255 green:(1-itemPer)*42.0/255 blue:(1-itemPer)*42.0/255 alpha:1];
        frontLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, (1+(1-itemPer)*SCALE_PER), (1+(1-itemPer)*SCALE_PER));
        tailLable.textColor = [UIColor colorWithRed:itemPer*165.0/255 green:itemPer*42.0/255 blue:itemPer*42.0/255 alpha:1];
        tailLable.transform = CGAffineTransformScale(CGAffineTransformIdentity, (1+itemPer*SCALE_PER), (1+itemPer*SCALE_PER));
        
        //改变下划线
        [UIView animateWithDuration:0.01f animations:^{
            _line.frame = CGRectMake(offsetX + 2, _line.frame.origin.y, [_itemsWidth[0] floatValue] - 4.0f, _line.frame.size.height);
        }];
    }
    
    [self setScrollViewOffsetByoffsetPercentage:currentOffsetPercentage];
}

- (void)updateData
{
    //    _arrowButton.backgroundColor = self.backgroundColor;
    
    //获取每个item的宽度
    _itemsWidth = [self getButtonsWidthWithTitles:_itemTitles byHeight:self.frame.size.height];
    if (_itemsWidth.count)
    {
        CGFloat contentWidth = [self contentWidthAndAddNavTabBarItemsWithButtonsWidth:_itemsWidth];
        _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
    }
}

- (void)refresh
{
    [self popItemMenuWith:_popItemMenu];
}

#pragma mark - SCFunctionView Delegate Methods
#pragma mark -

//点击pop后导航图的item的实现
- (void)itemPressedWithIndex:(NSInteger)index
{
    [self functionButtonPressed];
    
    //改变点击标题按钮的状态
    [self changeTitleColorWithAtIndex:index];
    
    [_delegate itemDidSelectedWithIndex:index];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
