//
//  HttpTool.h
//  WYNews
//
//  Created by lanou3g on 15/5/30.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


typedef void (^HttpSuccessBlock)(id JSON);
typedef void (^HttpFailureBlock)(NSError *error);

@interface HttpTool : NSObject

+ (void)postWitUrl:(NSString *)url Path:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure;

+ (void)getWithUrl:(NSString *)url Path:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure;

@end
