//
//  FloDatabaseEngin.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/30.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloDatabaseEngin.h"
#import "FMDB.h"
#import "FloStatusModel.h"
#import "comments.h"

#define kDatabaseName    @"weibo.db"

@implementation FloDatabaseEngin

// 类的初始化，在类第一次接收到消息前触发
+(void)initialize
{
    // 第一次将空的数据库copy到documet文件夹
    [FloDatabaseEngin copyDatabase2Document];
}

+ (NSString *)databasePath
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *databasePath = [docPath stringByAppendingPathComponent:kDatabaseName];
    return databasePath;
}

+(void)copyDatabase2Document
{
    NSString *databasePath = [FloDatabaseEngin databasePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:databasePath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"weibo" ofType:@"db"];
        [manager copyItemAtPath:sourcePath toPath:databasePath error:nil];
    }
}

#pragma mark - save data
+(NSArray *)columnOfTable:(NSString *)table
{
    NSMutableArray *columnArray = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[FloDatabaseEngin databasePath]];
    [db open];
    
    // 将表名转换为小写
    NSString *tableName = [table lowercaseString];
    
    // 查询表中所有字段名称
    FMResultSet *result = [db getTableSchema:tableName];
    while ([result next]) {
        [columnArray addObject:[result stringForColumn:@"name"]];
    }
    
    [db close];
    return columnArray;
}

//  动态构造 insert 语句
+(NSString *)createInsertSql4Table:(NSString *)table valueDict:(NSDictionary *)values
{
    NSArray *allKeys = [values allKeys];
    
    // 构造 column
    NSString *columnString = [allKeys componentsJoinedByString:@", "];
    // 构造key
    NSString *keyString = [allKeys componentsJoinedByString:@", :"];
    keyString = [@":" stringByAppendingString:keyString];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", table, columnString, keyString];
    return sql;
}

+(void)saveStatus2Table:(NSString *)table status:(NSArray *)status
{
    NSArray *statusTableColumn = [FloDatabaseEngin columnOfTable:table];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[FloDatabaseEngin databasePath]];
    [queue inDatabase:^(FMDatabase *db) {
        for (NSDictionary *statusInfo in status) {
            // 过滤字典中无用的值
            NSMutableDictionary *muSatatusInfo = [NSMutableDictionary dictionaryWithDictionary:statusInfo];
            NSArray *allkey = [statusInfo allKeys];
            for (NSString *key in allkey) {
                if (![statusTableColumn containsObject:key]) {
                    [muSatatusInfo removeObjectForKey:key];
                } else {
                    // 如果存在，取出来内容，判断是否需要归档存储
                    id object = statusInfo[key];
                    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
                        [muSatatusInfo setObject:data forKey:key];
                    }
                }
            }
            NSString *sql = [FloDatabaseEngin createInsertSql4Table:table valueDict:muSatatusInfo];
            [db executeUpdate:sql withParameterDictionary:muSatatusInfo];
        }
    }];
}

#pragma mark - select status
+(NSArray *)selectStatusFromDatabase
{
    
    // 查询语句，按 id 降序排列，一次查询20条记录
    NSString *sql = @"select * from status order by id desc limit 20";
    return [FloDatabaseEngin selectDataWithSQLString:sql];
}

+(NSArray *)selectPublicStatusFromDatabase
{
    NSString *sql = @"select * from publicstatus order by id desc limit 20";
    return [FloDatabaseEngin selectDataWithSQLString:sql];
}

+(NSArray *)selectDataWithSQLString:(NSString *)sql
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FloDatabaseEngin databasePath]];
    [db open];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *statusArray = [NSMutableArray array];
    while ([result next]) {
        // 将查询结果转为字典并转化为微博对象
        NSDictionary *statusInfo = [result resultDictionary];
        NSMutableDictionary *muStatusInfo = [NSMutableDictionary dictionaryWithDictionary:statusInfo];
        
        // 将data数据转化为对象
        NSArray *allValues = [muStatusInfo allValues];
        for (id object in allValues) {
            if ([object isKindOfClass:[NSData class]]) {
                NSData *data = (NSData *)object;
                NSString *key = [[muStatusInfo allKeysForObject:object] firstObject];
                
                if ([key isEqualToString:kStatusPicUrls]) {
                    NSArray *picURLs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    // 给键重新赋值
                    [muStatusInfo setObject:picURLs forKey:key];
                } else if ([key isEqualToString:kStatusUserInfo]){
                    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [muStatusInfo setObject:userInfo forKey:key];
                    
                } else if ([key isEqualToString:kStatusRetweetStatus]){
                    NSDictionary *retweetStatus = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [muStatusInfo setObject:retweetStatus forKey:key];
                }
            }
        }
        
        FloStatusModel *statusModel = [[FloStatusModel alloc] initWithDictionary:muStatusInfo];
        [statusArray addObject:statusModel];
    }
    
    [db close];
    return statusArray;
}

+(void)resetDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FloDatabaseEngin databasePath]];
    [db open];
    
    NSString *sql = @"delete from status";
    [db executeUpdate:sql];
    NSString *publicStr = @"delete from publicstatus";
    [db executeUpdate:publicStr];
    
    [db close];
}

@end
