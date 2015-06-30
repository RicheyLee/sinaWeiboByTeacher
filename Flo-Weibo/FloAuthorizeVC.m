//
//  FloAuthorizeVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/17.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloAuthorizeVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"

@implementation FloAuthorizeVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 隐藏标签栏，在“发现”页面willAppera显示标签栏。
    self.tabBarController.tabBar.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@&response_type=code",kAppKey,kRedirectURL];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.webview loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlStr = [[request URL] absoluteString];
    if ([urlStr hasPrefix:kRedirectURL]) {
        // 取出回调url中的code值
        NSArray *result = [urlStr componentsSeparatedByString:@"code="];
        NSString *code = [result lastObject];
        
        // access_token请求
        NSDictionary *parameters = @{@"client_id":kAppKey,
                                     @"client_secret":kAppSecret,
                                     @"grant_type":kGrantType,
                                     @"code":code,
                                     @"redirect_uri":kRedirectURL};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        // MIMEType:媒体类型
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        

        [manager POST:kAccessTokenURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            
            // 更新授权信息
            [[FloAuthorization sharedAuthorization] loginSuccess:result];
            
            //清除cookies
            [self removeCookieAndCache];
            
            // 如果是模态的出现登陆页，则登陆成功后dismiss
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    return YES;
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self hiddenTabBar:NO];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

- (void)removeCookieAndCache
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
