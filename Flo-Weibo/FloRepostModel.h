//
//  FloRepostModel.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FloUserInfo;

@interface FloRepostModel : NSObject

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *repostStatusID;
@property (nonatomic, copy) NSString *repostText;
@property (nonatomic, strong) FloUserInfo *userInfo;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
