//
//  HttpTool.m
//  WYNews
//
//  Created by lanou3g on 15/5/30.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "HttpTool.h"

@implementation HttpTool
+ (void)requestWithUrl:(NSString *)url Path:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure method:(NSString *)method
{
    // 1.创建post请求
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    // 拼接传进来的参数
    if (params) {
        [allParams setDictionary:params];
    }
    
    // 拼接token参数
//    NSString *token = [AccountTool sharedAccountTool].account.accessToken;
//    if (token) {
//        [allParams setObject:token forKey:@"access_token"];
//    }
    
    NSURLRequest *post = [client requestWithMethod:method path:path parameters:allParams];
    
    // 2.创建AFJSONRequestOperation对象
    NSOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:post
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    if (success == nil) return;
        success(JSON);
      }failure : ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
      if (failure == nil) return;
      failure(error);
     }];
    
    // 3.发送请求
    [op start];
}

+ (void)postWitUrl:(NSString *)url Path:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{
    [self requestWithUrl:url Path:path params:params success:success failure:failure method:@"POST"];
}

+ (void)getWithUrl:(NSString *)url Path:(NSString *)path params:(NSDictionary *)params success:(HttpSuccessBlock)success failure:(HttpFailureBlock)failure
{
    [self requestWithUrl:url Path:path params:params success:success failure:failure method:@"GET"];
}

@end
