//
//  FloUserInfo.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloUserInfo : NSObject

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, copy) NSString *name;
@property (nonatomic      ) int      level;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *userDescription;
@property (nonatomic, copy) NSString *blogURL;
@property (nonatomic, copy) NSString *userIconURL;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic      ) BOOL     isFollowing;
@property (nonatomic      ) int      statusCount;
@property (nonatomic      ) int      followingCount;
@property (nonatomic      ) int      followerCount;
@property (nonatomic      ) int      favouriteCount;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic      ) BOOL     isVerified;
@property (nonatomic, copy) NSString *verifiedReason;
@property (nonatomic, copy) NSString *iconLargeURl;
@property (nonatomic      ) int      bothFolloweringCount;
@property (nonatomic)       int      userRank;
@property (nonatomic, copy) NSString *verifiedSource;

- (instancetype)initWithDictionary:(NSDictionary *)userInfo;

- (NSDictionary *)dictionary;

@end
