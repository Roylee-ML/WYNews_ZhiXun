//
//  ImgModel.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgModel : NSObject<NSCoding>
@property(nonatomic,strong) NSString * setname;
@property(nonatomic,strong) NSString * img1;
@property(nonatomic,strong) NSString * img2;
@property(nonatomic,strong) NSString * img3;
@property(nonatomic,strong) NSString * imgsum;
@property(nonatomic,strong) NSString * setid;
@property(nonatomic ,strong)NSString * photosetID;
@end
