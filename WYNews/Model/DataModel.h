//
//  DataModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject<NSCoding>

@property(nonatomic,strong) NSString * hasHead;
@property(nonatomic,strong) NSString * url_3w;
@property(nonatomic,strong) NSString * votecount;
@property(nonatomic,strong) NSString * replyCount;
@property(nonatomic,strong) NSString * digest;
@property(nonatomic,strong) NSString * url;
@property(nonatomic,strong) NSString * docid;
@property(nonatomic,strong) NSString * title;
@property(nonatomic,strong) NSString * source;
@property(nonatomic,strong) NSString * priority;
@property(nonatomic,strong) NSString * lmodify;
@property(nonatomic,strong) NSString * imgsrc;
@property(nonatomic,strong) NSString * subtitle;
@property(nonatomic,strong) NSString * boardid;
@property(nonatomic,strong) NSString * ptime;

@property(nonatomic,strong) NSString * imgsrc1;
@property(nonatomic,strong) NSString * imgsrc2;
@property(nonatomic,strong) NSString * skipType;
@property(nonatomic,strong) NSString * imgextra;
@property(nonatomic,strong) NSString * photosetID;
@property(nonatomic,strong) NSString * setid;
@end
