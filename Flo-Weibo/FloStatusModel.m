//
//  FloStatusModel.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/26.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloStatusModel.h"
#import "FloUserInfo.h"
#import "comments.h"
#import "FloAuthorization.h"
#import "AFNetworking.h"
#import "FloUtilities.h"

@implementation FloStatusModel

-(instancetype)initWithDictionary:(NSDictionary *)statusInfo
{
    self = [super init];
    if (self) {
        //设置属性
        //设置user属性
        NSDictionary *userInfo = statusInfo[kStatusUserInfo];
        self.user = [[FloUserInfo alloc] initWithDictionary:userInfo];
        
        // 获取微博来源
        self.source = [self sourceWithString:statusInfo[kStatusSource]];
        
        NSString *dateString = statusInfo[kStatusCreateTime];
        
        self.created_at = [FloUtilities dateWithDateString:dateString];
        
        self.text = statusInfo[kStatusText];
        
        // 最多显示8张图片
        NSMutableArray *picArray = [NSMutableArray arrayWithArray:statusInfo[kStatusPicUrls]];
        if (picArray.count > 8) {
            [picArray removeObjectAtIndex:picArray.count-1];
        }
        self.pic_urls = picArray;
        self.reposts_count = [statusInfo[kStatusRepostsCount] integerValue];
        self.comments_count = [statusInfo[kStatusCommentsCount] integerValue];
        self.attitudes_count = [statusInfo[kStatusAttitudesCount] integerValue];
        
        //根据有无转发微博，创建微博对象
        // 注意可能存在 NSNull
        NSDictionary *reStatusInfo = statusInfo[kStatusRetweetStatus];
        if (reStatusInfo && ![reStatusInfo isKindOfClass:[NSNull class]]) {
            self.reStatus = [[FloStatusModel alloc] initWithDictionary:reStatusInfo];
        }
        
        // id作为微博请求参数
        self.statusID = statusInfo[kStatusID];
    }
    
    return self;
}
//重写get方法
-(NSString *)timeAgo{
    //计算跟当前时间的时间差
    NSTimeInterval time = -[self.created_at timeIntervalSinceNow];
    
    if (time < 60) {
        return @"刚刚";
    }else if (time < 3600) {
        return [NSString stringWithFormat:@"%ld 分钟前", (NSInteger)time/60];
    }else if (time < 3600 * 24) {
        return [NSString stringWithFormat:@"%ld 小时前", (NSInteger)time/3600];
    }else if (time < 3600 * 24 * 30){
        return [NSString stringWithFormat:@"%ld 天前", (NSInteger)time/(3600 * 24)];
    }else{
        return [NSDateFormatter localizedStringFromDate:self.created_at dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
}

//"<a href=\"http://app.weibo.com/t/feed/5yiHuw\" rel=\"nofollow\">iPhone 6 Plus</a>"
//从这其中找出正文
//">.*<"

-(NSString *)sourceWithString:(NSString *)string{
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

+(void)favoriteStatus:(NSString *)statusID
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    if (authorization.token) {
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     kStatusID:statusID};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:kFavoriteStatusURl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"收藏成功"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"收藏失败"];
        }];
    } else {
        return;
    }
}

+(void)cancelFavoriteStatus:(NSString *)statusID
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    if (authorization.token) {
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     kStatusID:statusID};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:kFavoriteCancelURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"取消收藏成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCancelFavoriteSuccess object:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"取消收藏失败"];
        }];
    } else {
        return;
    }
}


@end
