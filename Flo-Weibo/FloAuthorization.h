//
//  FloAuthorization.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/19.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloAuthorization : NSObject<NSCoding>

@property (nonatomic, copy  ) NSString *token;
@property (nonatomic, strong) NSDate   *expiresDate;
@property (nonatomic, copy  ) NSString *UID;

+ (FloAuthorization *)sharedAuthorization;

- (void)loginSuccess:(NSDictionary *)dic;

- (BOOL)isLogin;

- (void)logout;
+(void)reLogin:(NSString *)userID;

- (NSMutableDictionary *)requestParameters;

@end
