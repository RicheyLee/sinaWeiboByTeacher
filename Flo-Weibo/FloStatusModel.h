//
//  FloStatusModel.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/26.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FloUserInfo;

@interface FloStatusModel : NSObject

@property (nonatomic, strong) FloUserInfo    *user;
@property (nonatomic, strong) NSString       *source;
@property (nonatomic, strong) NSDate         *created_at;
@property (nonatomic, strong) NSString       *text;
@property (nonatomic, strong) NSArray        *pic_urls;
@property (nonatomic        ) NSInteger      reposts_count;
@property (nonatomic        ) NSInteger      comments_count;
@property (nonatomic        ) NSInteger      attitudes_count;
@property (nonatomic, strong) FloStatusModel *reStatus;
@property (nonatomic, strong) NSString       *statusID;

//显示的多长时间前创建的微博
@property(nonatomic)NSString *timeAgo;

//初始化model
-(instancetype)initWithDictionary:(NSDictionary *)statusInfo;

// 收藏微博
+(void)favoriteStatus:(NSString *)statusID;
+(void)cancelFavoriteStatus:(NSString *)statusID;

@end
