//
//  DataBaseHandle.h
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@interface DataBaseHandle : NSObject

+(DataBaseHandle*)sharedInstanc;

//创建数据库路径
+(NSString*)databaseFilePath;

//创建数据库
+(void)creatDataBase;

//创建表
+(void)creatTable;

//插入数据
+(void)insertDBWWithArra:(NSArray*)dataArray byID:(NSString*)model_id;

//通过ID获取数据
+(NSArray*)getDataArrayWithTitleid:(NSString*)titleID;

//插入数据
+(void)insertDBWWithDictionary:(NSDictionary*)dataDic byID:(NSString*)model_id;

//通过ID获取数据
+(NSDictionary*)getDataDictionaryWithTitleid:(NSString*)titleID;

//更新数据库
+(void)updateDataBaseWithDictionary:(NSDictionary*)dbDic;

//通过ID删除数据
+(void)deleteDataByTitleID:(NSString*)titleID;

//删除所有数据
+(void)deleteAllData;

@end
