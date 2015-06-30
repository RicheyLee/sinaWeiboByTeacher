//
//  FloSettingTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/27.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloSettingTVC.h"
#import "FloAccountManagerTVC.h"
#import "comments.h"
#import "FloMeTVC.h"
#import "FloAboutVC.h"
#import <SDWebImageManager.h>
#import "FloDatabaseEngin.h"

@interface FloSettingTVC ()<UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation FloSettingTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[@"账号管理", @"关于微博", @"清除缓存"];
}

- (IBAction)backBarButton:(id)sender {
    [self hiddenTabBar:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 0;
    switch (section) {
        case 0:
            num = 1;
            break;
        case 1:
            num = 2;
            break;
        case 2:
            num = 1;
            break;
        default:
            break;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exitCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            cell.textLabel.text = _dataArray[0];
        } else {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = _dataArray[1];
                    break;
                case 1:
                    cell.textLabel.text = _dataArray[2];
                    break;
                default:
                    break;
            }
        }
    }
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (indexPath.section == 0) {
        FloAccountManagerTVC *accountManagerTVC = [storyboard instantiateViewControllerWithIdentifier:kAccountManagerTVC];
        
        [self.navigationController pushViewController:accountManagerTVC animated:YES];
    } else if (indexPath.section == 2){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"退出微博?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出微博" otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
    } else{
        if (indexPath.row == 0) {
            FloAboutVC *aboutVC = [storyboard instantiateViewControllerWithIdentifier:@"aboutFloWeiboVC"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除所有缓存?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[SDWebImageManager sharedManager].imageCache clearDisk];
        [self removeCookieAndCache];
        [FloDatabaseEngin resetDatabase];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        exit(0);
    }
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
