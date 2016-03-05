//
//  HeadView.h
//  WYNews
//
//  Created by lanou3g on 15/6/2.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadModel.h"
#import "UIImageView+WebCache.h"
#import "DataModel.h"


@protocol pushDetail <NSObject>

-(void)pushphotoDetailViewControllerWithID:(NSString*)setid;

@end

@interface HeadView : UIView

@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)UIPageControl * pageControl;
@property(nonatomic,strong)NSMutableArray * ModelArray;

@property(nonatomic,weak) id<pushDetail> delegate;


-(instancetype)initWithFrame:(CGRect)frame;

-(void)refreshHeadViw;

-(void)refreshViewUI;

@end
