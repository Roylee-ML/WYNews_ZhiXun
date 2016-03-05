//
//  PhotosetDetailController.h
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotosetDetail.h"
#import "CustView.h"
#import "PhotosetView.h"

#define URLSET(setid) [NSString stringWithFormat:@"http://c.3g.163.com/photo/api/set/%@.json",setid]

typedef void(^LoadBlock)(id);

@interface PhotosetDetailController : UIViewController<UIScrollViewDelegate,presentViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) PhotosetDetail * photosetDetail;
@property (nonatomic,strong) NSMutableArray * photosArray;//photos
@property (nonatomic,strong) UILabel * setnamelabel;
@property (nonatomic,strong) UILabel * imgsumlabel;
@property (nonatomic,strong) UITextView * noteText;
@property (nonatomic,strong) UILabel * imgNumLabel;
@property (nonatomic,strong) UILabel * label;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) PhotosetDetail *photo;
@property (nonatomic,strong) NSMutableArray *textArray;
@property (nonatomic,strong) PhotosetView * photosView;
@property (nonatomic,strong) NSString * setid;//传值
@end
