//
//  FloRepostModel.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloRepostModel.h"
#import "comments.h"
#import "FloUtilities.h"
#import "FloUserInfo.h"

@implementation FloRepostModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.repostStatusID = dic[kCommontID];
        self.repostText = dic[kCommontText];
        self.userInfo = [[FloUserInfo alloc] initWithDictionary:dic[kCommontUser]];
        
        NSDate *date = [FloUtilities dateWithDateString:dic[kCommontCreated_at]];
        self.time = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    }
    return self;
}


@end
