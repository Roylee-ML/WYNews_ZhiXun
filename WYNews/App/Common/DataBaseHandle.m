//
//  DataBaseHandle.m
//  WYNews
//
//  Created by lanou3g on 15/5/28.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "DataBaseHandle.h"

@interface DataBaseHandle()
{
    
}
@end

@implementation DataBaseHandle

+(DataBaseHandle*)sharedInstanc
{
    static id handle;
    static dispatch_once_t once;
    dispatch_once(&once,^(){
        handle = [[DataBaseHandle alloc]init];
    });
    return handle;
}

//创建数据库路径
+(NSString*)databaseFilePath
{
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString * dbPath  = [docPath stringByAppendingString:@"news.sqlite"];
    
    NSLog(@"path ==== %@",dbPath);
    
    return dbPath;
}

static FMDatabase * _db = nil;
//创建数据库
+(void)creatDataBase
{
    _db = [FMDatabase databaseWithPath:[self databaseFilePath]];
}

//创建表
+(void)creatTable
{
    if (!_db) {
        [self creatDataBase];
    }
    
    //打开数据库,并判断数据库是否打开成功
    if (![_db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //为数据库设置缓存，提高查询效率
    [_db setShouldCacheStatements:YES];
    
    //判断数据库中是否已经存在这个表，如果不存在则创建该表
    if(![_db tableExists:@"news"])
    {
        BOOL result = [_db executeUpdate:@"CREATE TABLE news(news_id TEXT PRIMARY KEY, data BLOB) "];
        if (result) {
            NSLog(@"创建成功");
        }
    }
    
//    [_db close];
}

//插入数据
+(void)insertDBWWithArra:(NSArray*)dataArray byID:(NSString*)model_id
{
    if (!_db) {
        [self creatDataBase];
    }
    if (![_db open]) {
        return;
    }
    
    [_db setShouldCacheStatements:YES];
    
    if (![_db tableExists:@"news"]) {
        [self creatTable];
    }
    
    //判断将要插入的数据是否存在
    //    NSString * model_id = [[modelDic allKeys] lastObject];
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dataArray forKey:model_id];
    [archiver finishEncoding];
    
    FMResultSet * set = [_db executeQuery:@"select data from news where news_id = ?",model_id];
    if ([set next]) {
        BOOL result = [_db executeUpdate:@"update news set data = ? where news_id = ?",data,model_id];
        if (result) {
            NSLog(@"刷新成功");
        }
    }else{
        BOOL result = [_db executeUpdate:@"INSERT INTO news (news_id,data) VALUES (?,?)",model_id,data];
        NSLog(@"result === %d",result);
    }
    
    [_db close];
}

//通过ID获取数据
+(NSArray*)getDataArrayWithTitleid:(NSString*)titleID
{
    if (!_db) {
        [self creatDataBase];
    }
    if (![_db open]) {
        return nil;
    }
    if (![_db tableExists:@"news"]) {
        [_db close];
        return nil;
    }
    NSArray * array = nil;
    FMResultSet * set = [_db executeQuery:@"select data from news where news_id = ?",titleID];
    if ([set next]) {
        NSData * data = [set dataForColumn:@"data"];
        NSKeyedUnarchiver * unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        array = [unArchiver decodeObjectForKey:titleID];
        [unArchiver finishDecoding];
    }
    [_db close];
    return array;
}

//插入数据
+(void)insertDBWWithDictionary:(NSDictionary*)dataDic byID:(NSString*)model_id
{
    if (!_db) {
        [self creatDataBase];
    }
    if (![_db open]) {
        return;
    }
    
    [_db setShouldCacheStatements:YES];
    
    if (![_db tableExists:@"news"]) {
        [self creatTable];
    }
    
    //判断将要插入的数据是否存在
    //    NSString * model_id = [[modelDic allKeys] lastObject];
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dataDic forKey:model_id];
    [archiver finishEncoding];
    
    FMResultSet * set = [_db executeQuery:@"select data from news where news_id = ?",model_id];
    if ([set next]) {
        BOOL result = [_db executeUpdate:@"update news set data = ? where news_id = ?",data,model_id];
        if (result) {
            NSLog(@"刷新成功");
        }
    }else{
        BOOL result = [_db executeUpdate:@"INSERT INTO news (news_id,data) VALUES (?,?)",model_id,data];
        NSLog(@"result === %d 插入成功!",result);
    }
    
    [_db close];
}

//通过ID获取数据
+(NSDictionary*)getDataDictionaryWithTitleid:(NSString*)titleID
{
    if (!_db) {
        [self creatDataBase];
    }
    if (![_db open]) {
        return nil;
    }
    if (![_db tableExists:@"news"]) {
        [_db close];
        return nil;
    }
    
    NSDictionary * dic = nil;
    FMResultSet * set = [_db executeQuery:@"select data from news where news_id = ?",titleID];
    if ([set next]) {
        NSData * data = [set dataForColumn:@"data"];
        NSKeyedUnarchiver * unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        dic = [unArchiver decodeObjectForKey:titleID];
        [unArchiver finishDecoding];
    }
    [_db close];
    return dic;
}


//更新数据库
+(void)updateDataBaseWithDictionary:(NSDictionary*)modelDic
{
    if (!_db) {
        [self creatDataBase];
    }
    if (![_db open]) {
        return;
    }
    
    [_db setShouldCacheStatements:YES];
    
    if (![_db tableExists:@"news"]) {
        [self creatTable];
    }
    
    //判断将要插入的数据是否存在
    NSString * model_id = [[modelDic allKeys] lastObject];
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:modelDic forKey:model_id];
    [archiver finishEncoding];
    
    FMResultSet * set = [_db executeQuery:@"select  * from news where news_id = ?",model_id];
    if ([set next]) {
        [_db executeUpdate:@"update news set data = ? where news_id = ?",data,model_id];
    }
    [_db close];
}

//通过ID删除数据
+(void)deleteDataByTitleID:(NSString*)titleID
{
    
    if (![_db open]) {
        return;
    }
    
    [_db setShouldCacheStatements:YES];
    
    if (![_db tableExists:@"news"]) {
        return;
    }
    
    [_db executeUpdate:@"delete from news where news_id = ?",titleID];
    
    [_db close];
}

//删除所有数据
+(void)deleteAllData
{
    if (![_db open]) {
        return;
    }
    
    [_db setShouldCacheStatements:YES];
    
    if (![_db tableExists:@"news"]) {
        return;
    }
    
    [_db executeUpdate:@"delete from news"];
    
    [_db close];
}

////封装查询插入方法
//-(void)getDataFromDB:(NSArray*)dataArray andUpdateDBWith:(NSString*)model_id
//{
//    NSDictionary * dataDic = [DataBaseHandle getDictionaryWithTitleid:model_id];
//    
//    
//    
//}

@end
