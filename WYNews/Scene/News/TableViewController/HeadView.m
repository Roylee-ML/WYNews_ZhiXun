//
//  HeadView.m
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "HeadView.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
//#define SELF_WIDETH [UIScreen mainScreen].bounds.size.width

@interface HeadView()<UIScrollViewDelegate>
{
    NSMutableArray * _btArray;
    UIImageView * imgView4;
    UILabel * titleLable4;
    UIImageView * imgView;
    UILabel * titleLable;
    UIImageView * imgView1;
    UILabel * titleLable1;
    UIImageView * imgView2;
    UILabel * titleLable2;
    UIImageView * imgView3;
    UILabel * titleLable3;
    
    //实现轮播图循环的重复视图
    UIImageView * imgView_0;
    UILabel * titleLable_0;
    
    UIImageView * imgView_5;
    UILabel * titleLable_5;
}

@property (nonatomic,strong) NSTimer * myTimer;

@end

@implementation HeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        
        [self setupViewsWith:frame];
        
        NSArray * dataArray = [DataBaseHandle getDataArrayWithTitleid:NSStringFromClass([self class])];
        if (dataArray) {
            self.ModelArray = [dataArray mutableCopy];
        }else{
            self.ModelArray=[[NSMutableArray alloc]init];
        }
        
        [self creatMyTimer];
    }
    return self;
}

-(void)refreshHeadViw
{
    //网络请求数据
    NSString * urlString=@"http://c.m.163.com/nc/ad/headline/0-4.html";
    NSURL * url=[[NSURL alloc]initWithString:urlString];
    //创建请求对象
    NSURLRequest * request=[NSURLRequest requestWithURL:url cachePolicy:(NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:60.0];
    //连接方式对象
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!data) {
            return ;
        }
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        DataModel * model4= [DataBaseHandle getDataArrayWithTitleid:HeadViewKey].lastObject;
        if (self.ModelArray.count != 0) {
            [self.ModelArray removeAllObjects];
        }
        [self.ModelArray addObject:model4];
        NSArray * array=dic[@"headline_ad"];
        for (int i=0; i<array.count; i++) {
            HeadModel * model=[[HeadModel alloc]init];
            NSDictionary * dic=array[i];
            [model setValuesForKeysWithDictionary:dic];
            [self.ModelArray addObject:model];
        }
        
        [DataBaseHandle insertDBWWithArra:_ModelArray byID:NSStringFromClass([self class])];
        
        [self refreshViewUI];
    }];
}

-(void)setupViewsWith:(CGRect)frame
{
    //创建scrollView
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.scrollView.contentSize=CGSizeMake(7*frame.size.width, frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0); //初始一个视图的宽度
    self.scrollView.pagingEnabled=YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    
    //创建轮播图实现的重复视图头图imgview
    imgView_0=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView_0.contentMode = UIViewContentModeScaleAspectFill;
    imgView_0.clipsToBounds = YES;
    
    titleLable_0=[[UILabel alloc]initWithFrame:CGRectMake(5,self.scrollView.frame.size.height-0.053*WIDTH-3 , self.scrollView.frame.size.width-5, 0.053*WIDTH )];
    titleLable_0.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button_0=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button_0.backgroundColor=[UIColor clearColor];
    button_0.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button_0 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    
    //创建imgview
    imgView4=[[UIImageView alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView4.contentMode = UIViewContentModeScaleAspectFill;
    imgView4.clipsToBounds = YES;
    
    //创建lable
    titleLable4=[[UILabel alloc]initWithFrame:CGRectMake(self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH -3, self.scrollView.frame.size.width-5, 0.053*WIDTH)];
    titleLable4.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button4=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button4.backgroundColor=[UIColor clearColor];
    button4.frame=CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button4 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    //创建imgview 添加到scrollview上面
    imgView=[[UIImageView alloc]initWithFrame:CGRectMake(2 * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    
    titleLable=[[UILabel alloc]initWithFrame:CGRectMake(2 * self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH-3 , self.scrollView.frame.size.width-5, 0.053*WIDTH )];
    titleLable.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    
    UIButton * button=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button.backgroundColor=[UIColor clearColor];
    button.frame=CGRectMake(2 * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    
    imgView1=[[UIImageView alloc]initWithFrame:CGRectMake(3*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView1.contentMode = UIViewContentModeScaleAspectFill;
    imgView1.clipsToBounds = YES;
    
    titleLable1=[[UILabel alloc]initWithFrame:CGRectMake(3*self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH -3, self.scrollView.frame.size.width-5, 0.053*WIDTH)];
    titleLable1.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button1=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button1.backgroundColor=[UIColor clearColor];
    button1.frame=CGRectMake(3*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button1 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    
    
    imgView2=[[UIImageView alloc]initWithFrame:CGRectMake(4*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView2.contentMode = UIViewContentModeScaleAspectFill;
    imgView2.clipsToBounds = YES;
    
    titleLable2=[[UILabel alloc]initWithFrame:CGRectMake(4*self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH-3 , self.scrollView.frame.size.width-5, 0.053*WIDTH)];
    titleLable2.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button2=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button2.backgroundColor=[UIColor clearColor];
    button2.frame=CGRectMake(4*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button2 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    
    
    
    imgView3=[[UIImageView alloc]initWithFrame:CGRectMake(5*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-5)];
    imgView3.contentMode = UIViewContentModeScaleAspectFill;
    imgView3.clipsToBounds = YES;
    
    titleLable3=[[UILabel alloc]initWithFrame:CGRectMake(5*self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH -3, self.scrollView.frame.size.width-5, 0.053*WIDTH)];
    titleLable3.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button3=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button3.backgroundColor=[UIColor clearColor];
    button3.frame=CGRectMake(5*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button3 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    
    //创建轮播图实现的重复视图尾图imgview
    imgView_5=[[UIImageView alloc]initWithFrame:CGRectMake(6*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height-0.053*WIDTH-6)];
    imgView_5.contentMode = UIViewContentModeScaleAspectFill;
    imgView_5.clipsToBounds = YES;
    
    //创建lable
    titleLable_5=[[UILabel alloc]initWithFrame:CGRectMake(6*self.scrollView.frame.size.width+5,self.scrollView.frame.size.height-0.053*WIDTH -3, self.scrollView.frame.size.width-5, 0.053*WIDTH)];
    titleLable_5.font = [UIFont fontWithName:WAWA_FONT size:TitleFont_Size-2];
    
    UIButton * button_5=[UIButton buttonWithType:(UIButtonTypeSystem)];
    button_5.backgroundColor=[UIColor clearColor];
    button_5.frame=CGRectMake(6*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [button_5 addTarget:self action:@selector(pushPhotoViewController:) forControlEvents:(UIControlEventTouchUpInside )];
    
    _btArray =[[NSMutableArray alloc]init];
    [_btArray addObject:button4];
    [_btArray addObject:button];
    [_btArray addObject:button1];
    [_btArray addObject:button2];
    [_btArray addObject:button3];
    [_btArray addObject:button_5];
    [_btArray addObject:button_0];
    
    [self.scrollView addSubview:imgView];
    [self.scrollView addSubview:imgView1];
    [self.scrollView addSubview:imgView2];
    [self.scrollView addSubview:imgView3];
    [self.scrollView addSubview:imgView4];
    [self.scrollView addSubview:imgView_0];
    [self.scrollView addSubview:imgView_5];
    [self.scrollView addSubview:titleLable];
    [self.scrollView addSubview:titleLable1];
    [self.scrollView addSubview:titleLable2];
    [self.scrollView addSubview:titleLable3];
    [self.scrollView addSubview:titleLable4];
    [self.scrollView addSubview:titleLable_0];
    [self.scrollView addSubview:titleLable_5];
    [self.scrollView addSubview:button];
    [self.scrollView addSubview:button1];
    [self.scrollView addSubview:button2];
    [self.scrollView addSubview:button3];
    [self.scrollView addSubview:button4];
    [self.scrollView addSubview:button_0];
    [self.scrollView addSubview:button_5];
    
    [self addSubview:self.scrollView];
    
    //设置pagecontrol
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width*2/3, self.frame.size.height -15, self.frame.size.width/3, 10)];
    _pageControl.center = CGPointMake(_pageControl.center.x, titleLable.center.y);
    _pageControl.numberOfPages = 5;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:165.0/255 green:42.0/255 blue:42.0/255 alpha:1];
    [_pageControl addTarget:self action:@selector(changeScrollViewOffset) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_pageControl];

}

-(void)refreshViewUI
{
    DataModel * model4= self.ModelArray[0];
    [imgView4 sd_setImageWithURL:[NSURL URLWithString:model4.imgsrc]];
    titleLable4.text=model4.title;
    
    
    HeadModel * model=self.ModelArray[1];
    [imgView sd_setImageWithURL:[NSURL URLWithString:model.imgsrc]];
    titleLable.text=model.title;
    
    HeadModel * model1=self.ModelArray[2];
    [imgView1 sd_setImageWithURL:[NSURL URLWithString:model1.imgsrc]];
    titleLable1.text=model1.title;

    
    HeadModel * model2=self.ModelArray[3];
    [imgView2 sd_setImageWithURL:[NSURL URLWithString:model2.imgsrc]];
    titleLable2.text=model2.title;
    
    HeadModel * model3=self.ModelArray[4];
    [imgView3 sd_setImageWithURL:[NSURL URLWithString:model3.imgsrc]];
    titleLable3.text=model3.title;
    
    //轮播图头图的图片设置,与最后一张一样
    [imgView_0 sd_setImageWithURL:[NSURL URLWithString:model3.imgsrc]];
    titleLable_0.text=model3.title;
    
    //轮播图尾图的图片设置,与第一张一样
    [imgView_5 sd_setImageWithURL:[NSURL URLWithString:model4.imgsrc]];
    titleLable_5.text=model4.title;

}
-(void)pushPhotoViewController:(UIButton *)BI{
    
    NSInteger index = [_btArray indexOfObject:BI];
    if (index==0 || index == 5) {
        DataModel * model=_ModelArray[0];
        NSString * str=model.photosetID;
        
        if (!str) {
            str = model.docid;
        }
        
        [self.delegate pushphotoDetailViewControllerWithID:str];
        
    }else if (index == 6) {
        HeadModel * model=_ModelArray[4];
        NSString * str=[[model.url stringByReplacingOccurrencesOfString:@"|" withString:@"/"] substringFromIndex:4];
        
        [self.delegate pushphotoDetailViewControllerWithID:str];
    }else{
        HeadModel * model=_ModelArray[index];
        NSString * str=[[model.url stringByReplacingOccurrencesOfString:@"|" withString:@"/"] substringFromIndex:4];
        
        [self.delegate pushphotoDetailViewControllerWithID:str];
    }
}

//设置timer
-(void)creatMyTimer
{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }

/*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            _myTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0f] interval:3.0f target:self selector:@selector(changePage) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_myTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop]run];
        }
    });
*/
    
    _myTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0f] interval:3.0f target:self selector:@selector(changePage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_myTimer forMode:NSRunLoopCommonModes];
}

-(void)pauseMyTimer
{
    [_myTimer setFireDate:[NSDate distantFuture]];
}

-(void)startMyTimer
{
    [_myTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0f]];
}

-(void)invalidateMyTimer
{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}

-(void)changePage
{
    NSInteger page = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    if (page == 6) {
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
        page = 1;
    }
    page++;
    
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];
    
    if (page == 6) {
        self.pageControl.currentPage = 0;
//        self.scrollView.contentOffset = CGPointMake(0, 0);
    }else{
        self.pageControl.currentPage = page - 1;
    }

/*
    if (page == 6) {
        self.pageControl.currentPage = 0;
        [UIView animateWithDuration:0.3f animations:^{
            self.scrollView.contentOffset = CGPointMake(page * self.scrollView.frame.size.width, 0);
        } completion:^(BOOL finished) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
        }];
        
    }else{
        [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];
        self.pageControl.currentPage = page - 1;
    }
*/

/*
    //但显示最后一张时，能够立即显示正常英爱显示的第一张图。即回到第二张的位置
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        if (page == 6) {
            self.scrollView.contentOffset = CGPointMake(0 ,0);
            
            NSLog(@"barrier线程执行.......");
        }
    });
*/
    
}

-(void)changeScrollViewOffset
{
    NSInteger page = self.pageControl.currentPage;
    [self.scrollView setContentOffset:CGPointMake(++page * self.frame.size.width, 0) animated:YES];
}

#pragma mark -------scrollviewdelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self invalidateMyTimer];
    [self pauseMyTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    [self creatMyTimer];
    [self startMyTimer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSInteger off_x = (int)scrollView.contentOffset.x%(int)scrollView.frame.size.width;
    if (page == 6 && off_x == 0) {  //恰好滚动到最后一张视图
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0);
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSLog(@"page ======= %d",(int)page);
    if (page == 6) {
        scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
        self.pageControl.currentPage = 0;
    }else if (page == 0) {
        scrollView.contentOffset = CGPointMake(5 * self.scrollView.frame.size.width, 0);
        self.pageControl.currentPage = 4;
    }else{
        self.pageControl.currentPage = (page-1);
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
