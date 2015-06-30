//
//  FloAccountManagerTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/27.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloAccountManagerTVC.h"
#import "FloAccountCell.h"
#import "FloUserInfo.h"
#import "FloAuthorization.h"
#import "comments.h"
#import "FloAuthorizeVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FloAccountManagerTVC ()

@property (nonatomic, strong) NSMutableArray *accountArray;

@end

static NSString *docPath;

@implementation FloAccountManagerTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLeftBarButtonItem];
    
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docPath = [docPathArray objectAtIndex:0];

    [self getDataSource];
}

- (void)setLeftBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButton)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)leftBarButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDataSource
{
    _accountArray = [NSMutableArray array];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *allFile = [manager contentsOfDirectoryAtPath:docPath error:NULL];
    for (NSString *fileName in allFile) {
        if ([[fileName pathExtension] isEqualToString:@"plist"]) {
            NSString *fullFilePath = [docPath stringByAppendingPathComponent:fileName];
            NSDictionary *userInfoDic = [NSDictionary dictionaryWithContentsOfFile:fullFilePath];
            
            // 判断plist文件是否是用户信息文件
            if ([fileName isEqualToString:[NSString stringWithFormat:@"%@.plist",userInfoDic[kIDStr]]]) {
                FloUserInfo *userInfo = [[FloUserInfo alloc] initWithDictionary:userInfoDic];
                [_accountArray addObject:userInfo];
            }
        }
    }
}

- (void)logout2Relogin
{
    // 清除登陆信息
    [[FloAuthorization sharedAuthorization] logout];
    
    // 页面跳转
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // 通知tabBarController切换到发现页面，并弹出登陆页面
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginOut object:nil];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 0;
    if (section == 0) {
        num = _accountArray.count + 1;
    } else {
        num = 1;
    }
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        FloAccountCell *mycell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
        
        if (indexPath.row == _accountArray.count) {
            mycell.iconImageV.image = [UIImage imageNamed:@"accountmanage_add"];
            mycell.userName.text = @"添加账号";
        } else {
            // 提取用户头像
            FloUserInfo *userInfo = _accountArray[indexPath.row];
            [mycell.iconImageV sd_setImageWithURL:[NSURL URLWithString:userInfo.iconLargeURl]];
            
            // 设置用户名
            mycell.userName.text = userInfo.name;
        }
        
        cell = mycell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exitAccountCell" forIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathStr = [docPathArray firstObject];
        NSString *currentUserFilePath = [pathStr stringByAppendingPathComponent:kCurrentUserIDFile];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:currentUserFilePath]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定退出此账号?" message:nil
                                                           delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        } else {
            return;
        }
    } else {
        if (indexPath.row == _accountArray.count) {
            // 点击添加账号时，跳转到登陆页面
            [self logout2Relogin];
        } else {
            // 点击了其他账号，登陆到其他账号
            FloUserInfo *userInfo = _accountArray[indexPath.row];
            [FloAuthorization reLogin:userInfo.idStr];
            [self hiddenTabBar:NO];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = 60;
    } else {
        height = 44;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self logout2Relogin];
    }
}

@end
