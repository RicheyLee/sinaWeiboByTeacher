//
//  FloVCManager.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/25.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloVCManager.h"
#import "FloGuideVC.h"
#import "AppDelegate.h"

#define kIsNotFirstLaunch @"notFirstLaunch"

@implementation FloVCManager

+ (id)getRootVC
{
    //根据标识返回相应的控制器
    BOOL notFirstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:kIsNotFirstLaunch];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (notFirstLaunch) {
        return [storyboard instantiateViewControllerWithIdentifier:@"tabBarC"];
    } else {
        return [storyboard instantiateViewControllerWithIdentifier:@"guideVC"];
    }
}

+ (void)guideEnd
{
    //引导结束，更改标识位，切换根控制器
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:YES forKey:kIsNotFirstLaunch];
    [userDefault synchronize];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    delegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabBarC"];
}
@end
