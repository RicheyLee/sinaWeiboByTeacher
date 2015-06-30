//
//  FloCommentsModel.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FloUserInfo;
@class FloStatusModel;

@interface FloCommentsModel : NSObject

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *commentsID;
@property (nonatomic, copy) NSString *commentsText;
@property (nonatomic, strong) FloUserInfo *userInfo;
@property (nonatomic, strong) FloStatusModel *status;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
