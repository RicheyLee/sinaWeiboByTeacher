//
//  FloUserInfo.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserInfo.h"
#import "comments.h"

@implementation FloUserInfo

- (instancetype)initWithDictionary:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        self.idStr                = userInfo[kIDStr];
        self.name                 = userInfo[kScreenName];
        self.level                = [userInfo[kLevel] intValue];
        self.location             = userInfo[kLocation];
        self.userDescription      = userInfo[kDescription];
        self.blogURL              = userInfo[kBlogURL];
        self.userIconURL          = userInfo[kUserIconURL];
        self.sex                  = userInfo[kSex];
        self.isFollowing          = [userInfo[kIsFollowing] boolValue];
        self.statusCount          = [userInfo[kStatusCount] intValue];
        self.followingCount       = [userInfo[kFollowingCount] intValue];
        self.followerCount        = [userInfo[kFollowerCount] intValue];
        self.favouriteCount       = [userInfo[kFavouriteCount] intValue];
        self.createTime           = userInfo[kCreateTime];
        self.isVerified           = [userInfo[kIsVerified] boolValue];
        self.verifiedReason       = userInfo[kVerifiedReason];
        self.iconLargeURl         = userInfo[kIconLargeURL];
        self.bothFolloweringCount = [userInfo[kBothFollowingCount] intValue];
        self.userRank             = [userInfo[kUserRank] intValue];
        self.verifiedSource       = userInfo[kVerifiedSource];
    }
    return self;
}

-(NSDictionary *)dictionary
{
    NSDictionary *dic = @{kIDStr:self.idStr,
                          kScreenName:self.name,
                          kLevel:[NSNumber numberWithInt:self.level],
                          kLocation:self.location,
                          kDescription:self.description,
                          kBlogURL:self.blogURL,
                          kUserIconURL:self.userIconURL,
                          kSex:self.sex,
                          kIsFollowing:[NSNumber numberWithBool:self.isFollowing],
                          kStatusCount:[NSNumber numberWithInt:self.statusCount],
                          kFollowingCount:[NSNumber numberWithInt:self.followingCount],
                          kFollowerCount:[NSNumber numberWithInt:self.followerCount],
                          kFavouriteCount:[NSNumber numberWithInt:self.favouriteCount],
                          kCreateTime:self.createTime,
                          kIsVerified:[NSNumber numberWithBool:self.isVerified],
                          kVerifiedReason:self.verifiedReason,
                          kIconLargeURL:self.iconLargeURl,
                          kBothFollowingCount:[NSNumber numberWithInt:self.bothFolloweringCount],
                          kUserRank:[NSNumber numberWithInt:self.userRank],
                          kVerifiedSource:self.verifiedSource
                          };
    return dic;
}

@end
