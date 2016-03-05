//
//  FMViewController.h
//  WYNews
//
//  Created by lanou3g on 15/6/4.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsAPIUrl.h"
#import "FMTableViewCell.h"
#import "FMPlayListViewController.h"
#import "FMPlateViewController.h"

@interface FMViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PlayFMVideoDelegate,ShowPlayingAudio>

@end
