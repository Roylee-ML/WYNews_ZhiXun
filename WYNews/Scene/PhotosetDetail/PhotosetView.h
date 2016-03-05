//
//  PhotosetView.h
//  haha
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENDPhotos.h"
#import "UIImageView+WebCache.h"

#define URLS(setid) [NSString stringWithFormat:@"http://c.m.163.com/photo/api/related/%@.json",setid]

@protocol presentViewDelegate <NSObject>

- (void)presentView:(NSString*)setid;
@end

@interface PhotosetView : UIView

@property(nonatomic,assign)id<presentViewDelegate> delegate;
@property (nonatomic,strong) UIView * imageBgView1;
@property (nonatomic,strong) UIView * imageBgView2;
@property (nonatomic,strong) UIView * imageBgView3;
@property (nonatomic,strong) UIView * imageBgView4;
@property (nonatomic,strong) UIView * imageBgView5;

@property (nonatomic,strong) NSMutableArray * ENDPhotoArray;//用来存放model类
@property (nonatomic,strong) ENDPhotos * endPhotos1;
@property (nonatomic,strong) ENDPhotos * endPhotos2;
@property (nonatomic,strong) ENDPhotos * endPhotos3;
@property (nonatomic,strong) ENDPhotos * endPhotos4;
@property (nonatomic,strong) ENDPhotos * endPhotos5;
@property (nonatomic,strong) NSString * setid;

@property (nonatomic,strong) NSString * str1;
@property (nonatomic,strong) NSString * str2;
@property (nonatomic,strong) NSString * str3;
@property (nonatomic,strong) NSString * str4;
@property (nonatomic,strong) NSString * str5;

- (instancetype)initWithFrame:(CGRect)frame andID:(NSString*)setid;

@end
