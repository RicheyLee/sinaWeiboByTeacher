//
//  FloCommentsModel.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloCommentsModel.h"
#import "FloUserInfo.h"
#import "comments.h"
#import "FloUtilities.h"
#import "FloStatusModel.h"

@implementation FloCommentsModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.source = [FloUtilities sourceWithString:dic[kCommontSource]];
        self.commentsID = dic[kCommontID];
        self.commentsText = dic[kCommontText];
        self.userInfo = [[FloUserInfo alloc] initWithDictionary:dic[kCommontUser]];
        self.status = [[FloStatusModel alloc] initWithDictionary:dic[kStatus]];
        
        NSDate *date = [FloUtilities dateWithDateString:dic[kCommontCreated_at]];
        NSTimeInterval time = -[date timeIntervalSinceNow];
        if (time < 60) {
            self.time = @"刚刚";
        }else if (time < 3600) {
            self.time = [NSString stringWithFormat:@"%ld 分钟前", (NSInteger)time/60];
        }else if (time < 3600 * 24) {
            self.time = [NSString stringWithFormat:@"%ld 小时前", (NSInteger)time/3600];
        }else if (time < 3600 * 24 * 30){
            self.time = [NSString stringWithFormat:@"%ld 天前", (NSInteger)time/(3600 * 24)];
        }else{
            self.time = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        }
    }
    return self;
}

@end
