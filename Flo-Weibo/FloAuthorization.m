//
//  FloAuthorization.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/19.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloAuthorization.h"
#import "comments.h"
#import "FloDatabaseEngin.h"

static FloAuthorization *authorization;

@implementation FloAuthorization

+ (FloAuthorization *)sharedAuthorization
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // 判断归档文件是否存在，存在就从文件中读取数据
        NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathStr = docPathArray[0];
        NSString *currentUserFilePath = [pathStr stringByAppendingPathComponent:kCurrentUserIDFile];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:currentUserFilePath]) {
            NSDictionary *currentUserIDDic = [NSDictionary dictionaryWithContentsOfFile:currentUserFilePath];
            NSString *userID = currentUserIDDic[kCurrentUserID];
            
            NSString *authorizationFile = [pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_authorization",userID]];
            authorization = [NSKeyedUnarchiver unarchiveObjectWithFile:authorizationFile];
        } else {
            authorization = [[FloAuthorization alloc] init];
        }
    });
    return authorization;
}

- (void)loginSuccess:(NSDictionary *)dic
{
    self.token = dic[kAccessToken];
    self.expiresDate = [NSDate dateWithTimeIntervalSinceNow:[dic[kTokenTime] doubleValue]];
    self.UID = dic[kUID];
    
    // 本地归档保存authorization,以 用户名_authorization 命名
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = docPathArray[0];
    NSString *path = [pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_authorization",self.UID]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    [NSKeyedArchiver archiveRootObject:self toFile:path];
    
    // 更新当前用户.plist
    [self updateCurrentUserID:self.UID];
    
}

- (void)updateCurrentUserID:(NSString *)userID
{
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = docPathArray[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 本地保存当前登陆用户名 currentuserid.plist
    NSString *currentUserFilePath = [pathStr stringByAppendingPathComponent:kCurrentUserIDFile];
    if ([fileManager fileExistsAtPath:currentUserFilePath]) {
        [fileManager removeItemAtPath:currentUserFilePath error:nil];
    }
    NSDictionary *currentUserDic = @{kCurrentUserID:userID};
    [currentUserDic writeToFile:currentUserFilePath atomically:YES];
    
    // 登陆成功返回authorization对象
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess object:authorization];
}

- (BOOL)isLogin
{
    if (self.token) {
        return YES;
    }
    return NO;
}

+(void)reLogin:(NSString *)userID
{
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = docPathArray[0];
    NSString *authorizationFile = [pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_authorization",userID]];
    authorization = [NSKeyedUnarchiver unarchiveObjectWithFile:authorizationFile];
    
    [authorization updateCurrentUserID:userID];
}

- (void)logout
{
    self.token = nil;
    self.expiresDate = nil;
    self.UID = nil;
    
    // 重置数据库
    [FloDatabaseEngin resetDatabase];
    
    // 删除currentuserid.plist
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = docPathArray[0];
    NSString *currentUserFilePath = [pathStr stringByAppendingPathComponent:kCurrentUserIDFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:currentUserFilePath]) {
        [fileManager removeItemAtPath:currentUserFilePath error:nil];
    }    
}

// 构造请求参数
- (NSMutableDictionary *)requestParameters
{
    if ([self isLogin]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self.token forKey:kAccessToken];
        return dic;
    }
    return nil;
}

#pragma mark - NSCoding
// 解档
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.expiresDate = [aDecoder decodeObjectForKey:kTokenTime];
        if ([[NSDate date] compare:self.expiresDate] < 0) {
            self.token = [aDecoder decodeObjectForKey:kAccessToken];
            self.UID = [aDecoder decodeObjectForKey:kUID];
        } else {
            // 登陆超时，重新登陆
            return nil;
        }
    }
    return self;
}

// 归档
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.token forKey:kAccessToken];
    [aCoder encodeObject:self.expiresDate forKey:kTokenTime];
    [aCoder encodeObject:self.UID forKey:kUID];
}

@end
