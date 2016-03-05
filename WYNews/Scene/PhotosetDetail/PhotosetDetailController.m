//
//  PhotosetDetailController.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "PhotosetDetailController.h"
#import "UIImageView+WebCache.h"
#import "NSString+StringHeight.h"
#import "AllowPanBackScrollView.h"

#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define TABBAR_HEIGHT self.tabBarController.tabBar.frame.size.height

#define TITLT_FONT 18
#define INFO_FONT 14
#define NUM_FONT 14

@interface PhotosetDetailController ()

@property (nonatomic,strong) UIScrollView * mainView;

@end

@implementation PhotosetDetailController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBarHidden = YES;
    
    //    self.hidesBottomBarWhenPushed = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //title必须设置空，因为item由两部分组成。
    backItem.title = @"";
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }

    
/*创建滚动视图*/
    
    self.mainView= [[AllowPanBackScrollView alloc] initWithFrame:CGRectMake(0, 0,SELF_WIDTH,SELF_HEIGHT)];
    
    _mainView.backgroundColor = [UIColor blackColor];
    _mainView.pagingEnabled = YES;
    _mainView.contentSize = CGSizeMake(SELF_WIDTH, SELF_WIDTH);
    
    [self.view addSubview:_mainView];

/******************************************************/
/*
    *设置返回手势依赖关系
*/
    [_mainView.panGestureRecognizer requireGestureRecognizerToFail:[self screenEdgePanGestureRecognizer]];
    
/******************************************************/
    self.photosArray  = [@[] mutableCopy];
    self.textArray=[NSMutableArray array];
    
    //请求网络
    
    NSURL * url = [NSURL URLWithString:URLSET(_setid)];
    
    [self loadDataWithUrl:url byHandle:^(NSMutableDictionary * dataDic){
        
        NSArray * array = dataDic[@"photos"];
        for (NSDictionary * dict in array) {
            PhotosetDetail * photosDetail = [[PhotosetDetail alloc] init];
            [photosDetail setValuesForKeysWithDictionary:dict];
            [self.photosArray addObject:photosDetail];
            
            [self.textArray addObject:photosDetail.note];
        }
        
        //重新设置contentSize
        _mainView.contentSize=CGSizeMake((_photosArray.count+1) *CGRectGetWidth(_mainView.frame),0);
        
        //加载第一张图片
        CustView * custView_1 = [[CustView alloc] initWithFrame:CGRectMake(0 * CGRectGetWidth(_mainView.frame), 0, SELF_WIDTH, SELF_HEIGHT - NC_HEIGHT - STATUS_HEIGHT - TABBAR_HEIGHT)];
        
        custView_1.tag=100;
        
        [_mainView addSubview:custView_1];
        
    /*
        *设置手势依赖关系
    */
//        [_mainView.panGestureRecognizer requireGestureRecognizerToFail:custView_1.panGestureRecognizer];
        
        PhotosetDetail * photo_1 = (PhotosetDetail*)_photosArray[0];
        
        //进度显示
        MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:custView_1];
        [custView_1 addSubview:hud];
        hud.mode = MBProgressHUDModeIndeterminate;
        [hud show:YES];
        
        [custView_1.imageView sd_setImageWithURL:[NSURL URLWithString:photo_1.imgurl] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [hud hide:YES];
            
        }];
        
        //设置自定义图片view
        for (int i=1; i<self.photosArray.count; i++) {
            CustView * custView = [[CustView alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(_mainView.frame), 0, SELF_WIDTH, SELF_HEIGHT - NC_HEIGHT - STATUS_HEIGHT - TABBAR_HEIGHT)];
            
            custView.tag=100+i;
            
            [_mainView addSubview:custView];
        }
        
        //请求数据后加载视图
        [self setupViews];
        
        //设置标题
        
        self.imgsumlabel.text = [NSString stringWithFormat:@"/%@",[dataDic objectForKey:@"imgsum"]];
        
        CGFloat numWideth = [NSString textLableWideth:[dataDic objectForKey:@"imgsum"] andFont:[UIFont systemFontOfSize:20]];
        CGFloat textWideth = [NSString textLableWideth:_imgsumlabel.text andFont:[UIFont systemFontOfSize:NUM_FONT]];
        _imgsumlabel.frame = CGRectMake((SELF_WIDTH-10) - textWideth, _imgsumlabel.frame.origin.y, textWideth, SELF_WIDTH/20);
        _imgNumLabel.frame = CGRectMake(_imgsumlabel.frame.origin.x - numWideth, _imgsumlabel.frame.origin.y-1, numWideth, SELF_WIDTH/20);
        
        self.setnamelabel.text = [dataDic objectForKey:@"setname"];
        _noteText.text = _textArray[0];
        
        //最后设置代理
        _mainView.delegate = self;
    }];
    
    //    [self.navigationController.navigationBar setTranslucent:NO];
    //    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    //设置返回按钮
    
    UIButton * backBT = [[UIButton alloc]initWithFrame:CGRectMake(10, STATUS_HEIGHT + SELF_WIDTH/80, SELF_WIDTH/15, SELF_WIDTH/15)];
    [backBT setImage:[[UIImage imageNamed:BACK_ICON] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [backBT addTarget:self action:@selector(didClickleftBI:) forControlEvents:UIControlEventTouchUpInside];
    backBT.alpha = 0.8;
    [self.view addSubview:backBT];
    
    
}

//布局视图
-(void)setupViews
{
    
    //标题lable
    self.setnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SELF_HEIGHT-TABBAR_HEIGHT-SELF_WIDTH/3.6 ,SELF_WIDTH*4/5, SELF_WIDTH/20)];
    //设置属性
    _setnamelabel.textColor = [UIColor whiteColor];
    _setnamelabel.font = [UIFont systemFontOfSize:TITLT_FONT];
    
    //图片数量label
    self.imgsumlabel = [[UILabel alloc] initWithFrame:CGRectMake((SELF_WIDTH - 10) - SELF_WIDTH/40, _setnamelabel.frame.origin.y, SELF_WIDTH/40, SELF_WIDTH/20)];
    //设置属性
    _imgsumlabel.textColor = [UIColor whiteColor];
    _imgsumlabel.font = [UIFont systemFontOfSize:NUM_FONT];
    
    //图片下标label
    self.imgNumLabel= [[UILabel alloc] initWithFrame:CGRectMake(_label.frame.origin.x - SELF_WIDTH/40,  _label.frame.origin.y,SELF_WIDTH/40, _imgsumlabel.frame.size.height)];
    _imgNumLabel.textColor = [UIColor whiteColor];
    _imgNumLabel.textAlignment = NSTextAlignmentRight;
    _imgNumLabel.font = [UIFont systemFontOfSize:TITLT_FONT];
    
    _imgNumLabel.text = @"1";
    
    //图片详情textView
    self.noteText= [[UITextView alloc] initWithFrame:CGRectMake(5, _setnamelabel.frame.origin.y + _setnamelabel.frame.size.height + SELF_WIDTH/200, SELF_WIDTH-10, SELF_WIDTH/3.8)];
    
    _noteText.backgroundColor = [UIColor clearColor];
    _noteText.textColor = [UIColor whiteColor];
    _noteText.font = [UIFont systemFontOfSize:INFO_FONT];
    _noteText.editable = NO;
    _noteText.selectable = NO;
    
    
    
    
    [self.view addSubview:_setnamelabel];
    [self.view addSubview:_imgNumLabel];
    [self.view addSubview:_imgsumlabel];
    [self.view addSubview:_label];
    [self.view addSubview:_noteText];
}


- (void)didClickleftBI:(UIBarButtonItem *)BI
{
    NSLog(@"left");
    [self.navigationController popViewControllerAnimated:YES];
}

//异步下载数据
-(void)loadDataWithUrl:(NSURL*)url byHandle:(LoadBlock)handle
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        //请求对象
        NSData *data=[NSData dataWithContentsOfURL:url];
        
        if (!data) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary * dic =[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            
            handle(dic);
        });
    });
}

#pragma mark -------- 返回手势 --------

//获取边缘手势
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.navigationController.view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
            {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    
    return screenEdgePanGestureRecognizer;
}


#pragma  mark ------- 实现scrollerView代理中协议的方法
#pragma  mark -------- 滚动时触发的方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/SELF_WIDTH;
    
    CGFloat maxOffset = SELF_WIDTH*(_textArray.count -1);
    BOOL flag = scrollView.contentOffset.x <= maxOffset;
    
    CGFloat offset = ((NSInteger)scrollView.contentOffset.x)%((NSInteger)SELF_WIDTH);
    CGFloat percentage = offset/SELF_WIDTH;
    
    if (flag) {
        _imgNumLabel.text = [NSString stringWithFormat:@"%d",(int)index+1];
        int m=[_imgNumLabel.text intValue];
        _noteText.text=_textArray[m-1];
        
        _imgNumLabel.alpha = 1;
        _noteText.alpha = 1;
        _setnamelabel.alpha = 1;
        _imgsumlabel.alpha = 1;
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            _imgNumLabel.alpha = 1-percentage;
            _noteText.alpha = 1-percentage;
            _setnamelabel.alpha = 1-percentage;
            _imgsumlabel.alpha = 1-percentage;
        }];
        
        if (index == _textArray.count) {
            _imgNumLabel.alpha = 0;
            _noteText.alpha = 0;
            _setnamelabel.alpha = 0;
            _imgsumlabel.alpha = 0;
        }
    }
}

#pragma mark -------- 滚动停止触发的方法

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index =scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    
    @try {
        CustView * custview_b=(CustView *)[self.view viewWithTag:100+index+1];
        CustView * custview_f=(CustView *)[self.view viewWithTag:100+index-1];
        custview_b.zoomScale = 1;
        [custview_b resetFrame];
        custview_f.zoomScale = 1;
        [custview_f resetFrame];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    //动态加载图片
    [self loadImageAtIndex:index];
}

//动态加载图片
-(void)loadImageAtIndex:(NSInteger)index
{
    if (index>0 && index<_photosArray.count) {
        PhotosetDetail * photoModel = _photosArray[index];
        CustView * imgScrollView = (CustView*)[self.view viewWithTag:100+index];
        if (!imgScrollView.imageView.image) {
            
            //菊花进度
            MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:imgScrollView];
            [imgScrollView addSubview:hud];
            hud.mode = MBProgressHUDModeIndeterminate;
            [hud show:YES];
            
            [imgScrollView.imageView sd_setImageWithURL:[NSURL URLWithString:photoModel.imgurl] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                [hud hide:YES];
                
            }];
        }
    }else if (index >=_photosArray.count){
        if (!_photosView) {
            //设置尾图
            _photosView = [[PhotosetView alloc] initWithFrame:CGRectMake(_photosArray.count*SELF_WIDTH, NC_HEIGHT + STATUS_HEIGHT, SELF_WIDTH, SELF_HEIGHT-STATUS_HEIGHT -NC_HEIGHT) andID:_setid];
            [_mainView addSubview:_photosView];
            
            _photosView.delegate=self;
        }
    }
}

//点击尾图推出另一个连接的视图
- (void)presentView:(NSString *)setid
{
    PhotosetDetailController * photoVC = [[PhotosetDetailController alloc]init];
    
    photoVC.setid = setid;
    
    [self.navigationController pushViewController:photoVC animated:YES];
}

@end
