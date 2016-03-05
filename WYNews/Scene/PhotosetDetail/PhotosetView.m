//
//  PhotosetView.m
//  haha
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "PhotosetView.h"
#import "UIImageView+WebCache.h"

#define SELF_WIDETH self.frame.size.width
#define SELF_HEIGHT self.frame.size.height

#define FONT 14

@interface PhotosetView()

@property (nonatomic,strong) NSMutableArray * imgViewArray;
@property (nonatomic,strong) NSMutableArray * lableArray;
@property (nonatomic,strong) NSString * setidFront;


@end

@implementation PhotosetView

- (instancetype)initWithFrame:(CGRect)frame andID:(NSString*)setid
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        
        //布局视图
        self.imgViewArray = [@[] mutableCopy];
        self.lableArray = [@[] mutableCopy];
        
        [self setupViewsWithFrame:frame];
        
        
        //发起网络请求
        
        NSURL * url = [NSURL URLWithString:URLS(setid)];
        
        _setidFront = [setid substringToIndex:4];
        //请求对象
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
            
            NSData * data = [NSData dataWithContentsOfURL:url];
            
            if (!data) {
                return ;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                self.ENDPhotoArray=[NSMutableArray array];
                for (NSDictionary * dic in array) {
                    ENDPhotos * photoDetail = [[ENDPhotos alloc] init];
                    [photoDetail setValuesForKeysWithDictionary:dic];
                    [_ENDPhotoArray addObject:photoDetail];
                }
                //加载图片
                [self loadImg];
                
            });
        });
    }
    return self;
}

//加载图片
-(void)loadImg
{
    for (int i=0; i<_imgViewArray.count; i++) {
        UIImageView * imgView =  (UIImageView*)_imgViewArray[i];
        ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[i];
        
        //设置文字
        UILabel * lable = (UILabel*)_lableArray[i];
        lable.text = endPhoto.setname;
        
        MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:imgView];
        [imgView addSubview:hud];
        hud.mode = MBProgressHUDModeIndeterminate;
        [hud show:YES];
        
        //加载图片
        [imgView sd_setImageWithURL:[NSURL URLWithString:endPhoto.cover] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [hud hide:YES];
        }];
    }
}

-(void)showNetworkBad:(MBProgressHUD*)hud
{
    [hud hide:YES];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您当前的网络不给力，请重新加载！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

//布局视图
-(void)setupViewsWithFrame:(CGRect)frame
{
    self.imageBgView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 50, frame.size.width/2,frame.size.height/4-20)];
    _imageBgView1.backgroundColor = [UIColor grayColor];
    self.imageBgView2 = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2, 50, frame.size.width/2,frame.size.height/4-20)];
    _imageBgView2.backgroundColor = [UIColor grayColor];
    self.imageBgView3 = [[UIView alloc]initWithFrame:CGRectMake(0,frame.size.height/4*1+30, frame.size.width, frame.size.height/4)];;
    _imageBgView3.backgroundColor = [UIColor grayColor];
    self.imageBgView4 = [[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height/4*2+30, frame.size.width/2, frame.size.height/4-40)];
    _imageBgView4.backgroundColor = [UIColor grayColor];
    self.imageBgView5 = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2, frame.size.height/4*2+30, frame.size.width/2, frame.size.height/4-40)];
    _imageBgView5.backgroundColor = [UIColor grayColor];
    
    UIView * bg_1 = [[UIView alloc] initWithFrame:CGRectMake(0, _imageBgView1.frame.size.height-SELF_WIDETH/12,frame.size.width/2, SELF_WIDETH/12)];
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, bg_1.frame.size.width-6, bg_1.frame.size.height)];
    label1.font = [UIFont systemFontOfSize:FONT];
    bg_1.backgroundColor = [UIColor blackColor];
    bg_1.alpha = 0.7;
    [bg_1 addSubview:label1];
    [_lableArray addObject:label1];
    
    UIView * bg_2 = [[UIView alloc] initWithFrame:CGRectMake(0,_imageBgView2.frame.size.height-SELF_WIDETH/12,frame.size.width/2, SELF_WIDETH/12)];
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, bg_2.frame.size.width-6, bg_2.frame.size.height)];
    label2.font = [UIFont systemFontOfSize:FONT];
    bg_2.backgroundColor = [UIColor blackColor];
    bg_2.alpha = 0.7;
    [bg_2 addSubview:label2];
    [_lableArray addObject:label2];
    
    UIView * bg_3 = [[UIView alloc] initWithFrame:CGRectMake(0, _imageBgView3.frame.size.height-SELF_WIDETH/12,frame.size.width, SELF_WIDETH/12)];
    UILabel * label3 = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, bg_3.frame.size.width-6, bg_3.frame.size.height)];
    label3.font = [UIFont systemFontOfSize:FONT];
    bg_3.backgroundColor = [UIColor blackColor];
    bg_3.alpha = 0.7;
    [bg_3 addSubview:label3];
    [_lableArray addObject:label3];
    
    UIView * bg_4 = [[UIView alloc] initWithFrame:CGRectMake(0, _imageBgView4.frame.size.height-SELF_WIDETH/12,frame.size.width/2, SELF_WIDETH/12)];
    UILabel * label4 = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, bg_4.frame.size.width-6, bg_4.frame.size.height)];
    label4.font = [UIFont systemFontOfSize:FONT];
    bg_4.backgroundColor = [UIColor blackColor];
    bg_4.alpha = 0.7;
    [bg_4 addSubview:label4];
    [_lableArray addObject:label4];
    
    UIView * bg_5 = [[UIView alloc] initWithFrame:CGRectMake(0, _imageBgView5.frame.size.height-SELF_WIDETH/12,frame.size.width/2, SELF_WIDETH/12)];
    UILabel * label5 = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, bg_5.frame.size.width-6, bg_5.frame.size.height)];
    label5.font = [UIFont systemFontOfSize:FONT];
    bg_5.backgroundColor = [UIColor blackColor];
    bg_5.alpha = 0.7;
    [bg_5 addSubview:label5];
    [_lableArray addObject:label5];
    
    
    label1.numberOfLines = 0;
    label2.numberOfLines = 0;
    label3.numberOfLines = 0;
    label4.numberOfLines = 0;
    label5.numberOfLines = 0;
    
    label1.textColor = [UIColor whiteColor];
    label2.textColor = [UIColor whiteColor];
    label3.textColor = [UIColor whiteColor];
    label4.textColor = [UIColor whiteColor];
    label5.textColor = [UIColor whiteColor];
    
    label1.font = [UIFont systemFontOfSize:16];
    label2.font = [UIFont systemFontOfSize:16];
    label3.font = [UIFont systemFontOfSize:16];
    label4.font = [UIFont systemFontOfSize:16];
    label5.font = [UIFont systemFontOfSize:16];
    
    label1.backgroundColor = [UIColor clearColor];
    label2.backgroundColor = [UIColor clearColor];
    label3.backgroundColor = [UIColor clearColor];
    label4.backgroundColor = [UIColor clearColor];
    label5.backgroundColor = [UIColor clearColor];
    
    
    [self addSubview:_imageBgView1];
    [self addSubview:_imageBgView2];
    [self addSubview:_imageBgView3];
    [self addSubview:_imageBgView4];
    [self addSubview:_imageBgView5];
    
    //imageView
    UIImageView *imageView1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_imageBgView1.frame), CGRectGetHeight(_imageBgView1.frame))];
    imageView1.layer.borderColor = [UIColor blackColor].CGColor;
    imageView1.layer.borderWidth = 1.0;
    imageView1.contentMode = UIViewContentModeScaleAspectFill;
    imageView1.clipsToBounds = YES;
    [_imageBgView1 addSubview:imageView1];
    [_imgViewArray addObject:imageView1];
    
    UIImageView *imageView2=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_imageBgView2.frame), CGRectGetHeight(_imageBgView2.frame))];
    imageView2.layer.borderColor = [UIColor blackColor].CGColor;
    imageView2.layer.borderWidth = 1.0;
    imageView2.contentMode = UIViewContentModeScaleAspectFill;
    imageView2.clipsToBounds = YES;
    [_imageBgView2 addSubview:imageView2];
    [_imgViewArray addObject:imageView2];
    
    UIImageView *imageView3=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_imageBgView3.frame), CGRectGetHeight(_imageBgView3.frame))];
    imageView3.layer.borderColor = [UIColor blackColor].CGColor;
    imageView3.layer.borderWidth = 1.0;
    imageView3.contentMode = UIViewContentModeScaleAspectFill;
    imageView3.clipsToBounds = YES;
    [_imageBgView3 addSubview:imageView3];
    [_imgViewArray addObject:imageView3];
    label3.text=_endPhotos3.setname;
    _str3 = _endPhotos3.setid;
    
    UIImageView *imageView4=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_imageBgView4.frame), CGRectGetHeight(_imageBgView4.frame))];
    imageView4.layer.borderColor = [UIColor blackColor].CGColor;
    imageView4.layer.borderWidth = 1.0;
    imageView4.contentMode = UIViewContentModeScaleAspectFill;
    imageView4.clipsToBounds = YES;
    [_imageBgView4 addSubview:imageView4];
    [_imgViewArray addObject:imageView4];
    
    
    UIImageView *imageView5=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_imageBgView5.frame), CGRectGetHeight(_imageBgView5.frame))];
    imageView5.layer.borderColor = [UIColor blackColor].CGColor;
    imageView5.layer.borderWidth = 1.0;
    imageView5.contentMode = UIViewContentModeScaleAspectFill;
    imageView5.clipsToBounds = YES;
    [_imageBgView5 addSubview:imageView5];
    [_imgViewArray addObject:imageView5];
    
    [_imageBgView1 addSubview:bg_1];
    [_imageBgView2 addSubview:bg_2];
    [_imageBgView3 addSubview:bg_3];
    [_imageBgView4 addSubview:bg_4];
    [_imageBgView5 addSubview:bg_5];
    
    
    //添加点击事件
    UITapGestureRecognizer *recogSG1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click1)];
    [_imageBgView1 addGestureRecognizer:recogSG1];
    
    UITapGestureRecognizer *recogSG2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click2)];
    [_imageBgView2 addGestureRecognizer:recogSG2];
    
    UITapGestureRecognizer *recogSG3=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click3)];
    [_imageBgView3 addGestureRecognizer:recogSG3];
    
    UITapGestureRecognizer *recogSG4=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click4)];
    [_imageBgView4 addGestureRecognizer:recogSG4];
    
    UITapGestureRecognizer *recogSG5=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click5)];
    [_imageBgView5 addGestureRecognizer:recogSG5];
    
}

-(void)click1
{
    ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[0];
    
    if ([self.delegate respondsToSelector:@selector(presentView:)]) {
        [self.delegate presentView:[NSString stringWithFormat:@"%@/%@",_setidFront,endPhoto.setid]];
    }
}

-(void)click2
{
    ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[1];
    
    if ([self.delegate respondsToSelector:@selector(presentView:)]) {
        [self.delegate presentView:[NSString stringWithFormat:@"%@/%@",_setidFront,endPhoto.setid]];
    }
}

-(void)click3
{
    
    ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[2];
    
    if ([self.delegate respondsToSelector:@selector(presentView:)]) {
        [self.delegate presentView:[NSString stringWithFormat:@"%@/%@",_setidFront,endPhoto.setid]];
    }
}

-(void)click4
{
    
    ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[3];
    
    if ([self.delegate respondsToSelector:@selector(presentView:)]) {
        [self.delegate presentView:[NSString stringWithFormat:@"%@/%@",_setidFront,endPhoto.setid]];
    }
}


-(void)click5
{
    ENDPhotos * endPhoto = (ENDPhotos*)_ENDPhotoArray[4];
    
    if ([self.delegate respondsToSelector:@selector(presentView:)]) {
        [self.delegate presentView:[NSString stringWithFormat:@"%@/%@",_setidFront,endPhoto.setid]];
    }
}

@end
