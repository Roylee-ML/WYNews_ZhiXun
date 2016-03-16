//
//  SCNavTabBarController.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBarController.h"
#import "CommonMacro.h"
#import "SCNavTabBar.h"
#import "AppDelegate.h"

#import "ImageTableViewController.h"
#import "FashionTableViewController.h"
#import "EmotionTableViewController.h"
#import "MilitaryTableViewController.h"
#import "BookTableViewController.h"
#import "FunnyTableViewController.h"
#import "EntertainTableViewController.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height



@interface SCNavTabBarController () <UIScrollViewDelegate, SCNavTabBarDelegate>
{
    NSInteger       _currentIndex;              // current page index
    
    
    SCNavTabBar     *_navTabBar;                // NavTabBar: press item on it to exchange view
    UIScrollView    *_mainView;                 // content view
}

@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -

- (id)initWithShowArrowButton:(BOOL)show
{
    self = [super init];
    if (self)
    {
        _showArrowButton = show;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController showArrowButton:(BOOL)show;
{
    self = [self initWithSubViewControllers:subControllers];
    
    _showArrowButton = show;
    [self addParentController:viewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initConfig];
    [self viewConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
#pragma mark -
- (void)initConfig
{
    // Iinitialize value
    _currentIndex = 1;
    _navTabBarColor = _navTabBarColor ? _navTabBarColor : NavTabbarColor;
    
    // Load all title of children view controllers
    //    _titles = [[NSMutableArray alloc] initWithCapacity:_subViewControllers.count];
    //    for (UIViewController *viewController in _subViewControllers)
    //    {
    //        [_titles addObject:viewController.title];
    //    }
    
}

- (void)viewInit
{
    // Load NavTabBar and content view to show on window
    _navTabBar = [[SCNavTabBar alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE + NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, (NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT)*9/16) showArrowButton:_showArrowButton];
    _navTabBar.delegate = self;
    _navTabBar.backgroundColor = [UIColor whiteColor];
    _navTabBar.lineColor = _navTabBarLineColor;
    _navTabBar.itemTitles = _titles;
    _navTabBar.arrowImage = _navTabBarArrowImage;
    _navTabBar.titleHeight = _navTabBar.frame.size.height;
    [_navTabBar updateData];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, _navTabBar.frame.origin.y + _navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - TAB_TAB_HEIGHT - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.bounces = _mainViewBounces;
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * _titles.count, SCREEN_HEIGHT - TAB_TAB_HEIGHT - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT);
    [self.view addSubview:_mainView];
    [self.view addSubview:_navTabBar];
    
}

- (void)viewConfig
{
    [self viewInit];
    
    // Load children view controllers and add to content view
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        [_mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
        
        //        NSLog(@"tableviewframe = %@",viewController.tableView);
    }];
    
    //    for (int idx = 0; idx<_subViewControllers.count; idx++) {
    //        CustomTableViewController *viewController = (CustomTableViewController *)_subViewControllers[idx];
    //        viewController.tableView.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
    //        [_mainView addSubview:viewController.tableView];
    //        [self addChildViewController:viewController];
    //    }
}

#pragma mark - Public Methods

- (void)setNavTabbarColor:(UIColor *)navTabbarColor
{
    // prevent set [UIColor clear], because this set can take error display
    CGFloat red, green, blue, alpha;
    if ([navTabbarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha)
    {
        navTabbarColor = NavTabbarColor;
    }
    _navTabBarColor = navTabbarColor;
}

- (void)addParentController:(UIViewController *)viewController
{
    // Close UIScrollView characteristic on IOS7 and later
    if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
}

//添加viewcontroller
-(void)addViewController:(UIViewController*)viewController atIndex:(NSInteger)index
{
    viewController.view.frame = CGRectMake(SCREEN_WIDTH*index, 0, SCREEN_WIDTH, _mainView.frame.size.height);
    
    [_mainView addSubview:viewController.view];
    [self.subViewControllers addObject:viewController];
    
    [self addChildViewController:viewController];
}

#pragma mark - Scroll View Delegate Methods
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    
    CGFloat per = scrollView.contentOffset.x*1.0/_mainView.contentSize.width;
    
    _navTabBar.currentItemIndex = _currentIndex;
    
    //    NSLog(@"index ===== %ld",_currentIndex);
    
    [_navTabBar setCurrentOffsetPercentage:per];
}

//滚动结束加载页面
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    _navTabBar.currentItemIndex = _currentIndex;
    
    //    NSLog(@"index ===-- %ld",_currentIndex);
    
    [self loadViewControllersAtIndex:_currentIndex];
}

#pragma mark ----- 动态加载viewcontroller ------

-(void)loadViewControllersAtIndex:(NSInteger)index
{
    
    BOOL allLoad = self.subViewControllers.count >= _titles.count;
    if (!allLoad) {
        switch (index) {
            case 1:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([ImageTableViewController class])]) {
                    
                    ImageTableViewController * imgTVC=[[ImageTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:imgTVC atIndex:1];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([ImageTableViewController class])];
                }
                break;
            case 2:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([FashionTableViewController class])]) {
                    
                    FashionTableViewController * fashionTVC=[[FashionTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:fashionTVC atIndex:2];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([FashionTableViewController class])];
                }
                break;
            case 3:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([MilitaryTableViewController class])]) {
                    
                    MilitaryTableViewController * militaryTVC=[[MilitaryTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:militaryTVC atIndex:3];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([MilitaryTableViewController class])];
                }
                break;
            case 4:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([EmotionTableViewController class])]) {
                    
                    EmotionTableViewController * emotionTVC=[[EmotionTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:emotionTVC atIndex:4];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([EmotionTableViewController class])];
                }
                break;
            case 5:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([BookTableViewController class])]) {
                    
                    BookTableViewController * bookTVC=[[BookTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:bookTVC atIndex:5];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([BookTableViewController class])];
                }
                break;
            case 6:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([FunnyTableViewController class])]) {
                    
                    FunnyTableViewController * funnyTVC=[[FunnyTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:funnyTVC atIndex:6];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([FunnyTableViewController class])];
                }
                break;
            case 7:
                if (![ShareManger isMarkedWithMark:NSStringFromClass([EntertainTableViewController class])]) {
                    
                    EntertainTableViewController * entertainTVC=[[EntertainTableViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
                    
                    [self addViewController:entertainTVC atIndex:7];
                    
                    [ShareManger setMarkWithMark:NSStringFromClass([EntertainTableViewController class])];
                }
                break;
            default:
                break;
        }
    }
}


#pragma mark - SCNavTabBarDelegate Methods
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    [_mainView scrollRectToVisible:CGRectMake(index * SCREEN_WIDTH, DOT_COORDINATE, _mainView.frame.size.width, _mainView.frame.size.height) animated:YES];
    [_mainView setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
    
    //加载视图
    [self loadViewControllersAtIndex:index];
}

- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
{
    [_navTabBar refresh];
    
    if (pop)
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, SELF_WIDTH, height);
        }];
        _navTabBar.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, (NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT)*9/16);
        }];
        _navTabBar.backgroundColor = [UIColor colorWithRed:250.0/255 green:250.0/255 blue:240.0/255 alpha:1];
    }
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
