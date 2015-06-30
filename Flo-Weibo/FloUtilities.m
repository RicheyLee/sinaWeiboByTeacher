//
//  FloUtilities.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUtilities.h"

@implementation FloUtilities

+(NSDate *)dateWithDateString:(NSString *)string
{
    //将时间字符串转化为时间
    //"Sun Apr 26 09:06:27 +0800 2015"
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //构造时间格式字符串
    NSString *formatterString = @"EEE MMM dd HH:mm:ss zzz yyyy";
    [formatter setDateFormat:formatterString];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

//"<a href=\"http://app.weibo.com/t/feed/5yiHuw\" rel=\"nofollow\">iPhone 6 Plus</a>"
//从这其中找出正文
//">.*<"

+(NSString *)sourceWithString:(NSString *)string{
    NSString *soure = nil;//保存结果；
    //定义的正则表达式字符串
    NSString *regExStr = @">.*<";
    //排除无效的情况
    if ([string isKindOfClass:[NSNull class]] || string == nil || [string isEqualToString:@""]) {
        return @"";
    }
    //构造正则
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regExStr options:0 error:nil];
    //查询出结果
    NSTextCheckingResult *result = [expression firstMatchInString:string options:0 range:NSMakeRange(0, string.length -1)];
    
    //取出子字符串
    if (result) {
        NSRange range = [result rangeAtIndex:0];
        soure = [string substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
    }
    return soure;
}

@end
