//
//  CommonDetailViewController.h
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDetailModel.h"
#import "NewsModel.h"
@interface CommonDetailViewController : UIViewController<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property(strong,nonatomic)NewsModel *newsModel;
@property(nonatomic,strong) NSString * docid;
@property(nonatomic,strong)UILabel * titleLabel;
@property(nonatomic,strong)UILabel * sourceLabel;
@property(nonatomic,strong)UILabel * ptimeLabel;
@property(nonatomic,strong)UILabel * bodyTextView;
@property(nonatomic,strong)UIWebView * webView;
@property(nonatomic,strong)UIActivityIndicatorView * activityIndicatorView;
@end
