//
//  FloDatabaseEngin.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/30.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloDatabaseEngin : NSObject

+ (void)saveStatus2Table:(NSString *)table status:(NSArray *)status;

+ (NSArray *)selectStatusFromDatabase;
+ (NSArray *)selectPublicStatusFromDatabase;

+ (void)resetDatabase;

@end
