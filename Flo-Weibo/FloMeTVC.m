//
//  FloMeTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloMeTVC.h"
#import "FloIconCell.h"
#import "FloCountCell.h"
#import "FloDefaultCell.h"
#import "FloAuthorization.h"
#import "FloUserInfo.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloSettingTVC.h"
#import "FloUserInfoTVC.h"
#import "FloAuthorizeVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FloUserinfoFriendsTVC.h"
#import "FloUserinfoFavoriteTVC.h"
#import "FloUserinfoPhotoTVC.h"

#define kIconCellId    @"iconCell"
#define kCountCellId   @"countCell"
#define kDefaultCellId @"defaultCell"
#define kDownload      @"isDownload"
#define kRequest       @"isRequest"
#define kFriendsTVC    @"friendsTVC"
#define kFavoriteTVC   @"favoriteStatusTVC"
#define kPhotoVC       @"userInfoPhotoVC"

@implementation FloMeTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.requestLock = NO;
    [self requestUserInfo];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestUserInfo) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutUpdateUI) name:kLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUpdateData) name:kLoginSuccess object:nil];
}
- (IBAction)settingAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSettingTVC *settingTVC = [storyboard instantiateViewControllerWithIdentifier:@"settingTVC"];
        
    [self.navigationController pushViewController:settingTVC animated:YES];
    // 隐藏标签栏
    [self hiddenTabBar:YES];
}

// 页面出现时定时刷新页面，消失时停止定时刷新
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.timer fire];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

#pragma mark - 请求用户信息更新UI
// 更新plist文件
- (void)updateLocationFile
{
    // 获取本地文件路径
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = docPathArray[0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",_userInfo.idStr]];
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:filePath]) {
        [fileMan removeItemAtPath:filePath error:nil];
    }
    
    NSDictionary *userInfoDic = [_userInfo dictionary];
    if (![userInfoDic writeToFile:filePath atomically:YES]) {
        NSLog(@"用户信息写入文件发生错误!");
    }
}

- (void)requestUserInfo
{
    if (!self.requestLock) {
        self.requestLock= YES;
    }else{
        return;
    }
    
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    if (authorization.token) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     kUID:authorization.UID};
        [manager GET:kUsersShowURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            self.userInfo = [[FloUserInfo alloc] initWithDictionary:result];
            
            // 获取用户信息成功更新头像
            [self updateLocationFile];
            
            [self.tableView reloadData];
            self.requestLock = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
            self.requestLock = NO;
        }];
    } else {
        self.requestLock = NO;
        return;
    }
}

#pragma mark - notifacation
- (void)loginUpdateData
{
    [self requestUserInfo];
}

- (void)logoutUpdateUI
{
    self.userInfo = nil;
    [self.tableView reloadData];
}


#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = 80;
        } else {
            height = 50;
        }
    } else {
        height = 44;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[FloAuthorization sharedAuthorization] isLogin]) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            if (_userInfo.idStr) {
                FloUserInfoTVC *userInfoTVC = [sb instantiateViewControllerWithIdentifier:kUserInfoTVC];
                userInfoTVC.userInfo = _userInfo;
                [self hiddenTabBar:YES];
                [self.navigationController pushViewController:userInfoTVC animated:YES];
            } else{
                return;
            }
        } else if (indexPath.section == 1){
            switch (indexPath.row) {
                case 0:
                {
                    FloUserinfoFriendsTVC *friendsTVC = [sb instantiateViewControllerWithIdentifier:kFriendsTVC];
                    friendsTVC.requestURL = kUserFriendsURL;
                    [self hiddenTabBar:YES];
                    [self.navigationController pushViewController:friendsTVC animated:YES];
                }break;
                case 1:
                {
                    FloUserinfoPhotoTVC *photoVC = [sb instantiateViewControllerWithIdentifier:kPhotoVC];
                    [self hiddenTabBar:YES];
                    [self.navigationController pushViewController:photoVC animated:YES];
                }break;
                case 2:
                {
                    FloUserinfoFavoriteTVC *favoriteTVC = [sb instantiateViewControllerWithIdentifier:kFavoriteTVC];
                    [self hiddenTabBar:YES];
                    [self.navigationController pushViewController:favoriteTVC animated:YES];
                }break;
                default:
                    break;
            }
            
        } else if (indexPath.section == 2){
            FloUserinfoFriendsTVC *friendsTVC = [sb instantiateViewControllerWithIdentifier:kFriendsTVC];
            if (indexPath.row == 0) {
                friendsTVC.requestURL = kUserInterestedURL;
            } else {
                friendsTVC.requestURL = kUserHotURL;
            }
            [self hiddenTabBar:YES];
            [self.navigationController pushViewController:friendsTVC animated:YES];
        } else {
            return;
        }
    } else {
        //未登录，转到登录页面
        FloAuthorizeVC *loginVC = [sb instantiateViewControllerWithIdentifier:kLoginVCIdentifier];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
    
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num;
    switch (section) {
        case 0:
            num = 2;
            break;
        case 1:
            num = 4;
            break;
        case 2:
            num = 2;
            break;
        default:
            break;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            FloIconCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:kIconCellId forIndexPath:indexPath];
            [myCell.iconView sd_setImageWithURL:[NSURL URLWithString:_userInfo.iconLargeURl]];
            myCell.userName.text = _userInfo.name;
            myCell.vipView.image = [UIImage imageNamed:@"userinfo_membership_expired"];
            if (_userInfo.userDescription.length > 0) {
                myCell.detailLabel.text = _userInfo.userDescription;
            } else {
                myCell.detailLabel.text = @"暂无简介";
            }
            cell = (UITableViewCell *)myCell;
        } else {
            FloCountCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:kCountCellId forIndexPath:indexPath];

            myCell.weiboCount.text = [NSString stringWithFormat:@"%d",_userInfo.statusCount];
            myCell.followingCount.text = [NSString stringWithFormat:@"%d",_userInfo.followingCount];
            myCell.followerCount.text = [NSString stringWithFormat:@"%d",_userInfo.followerCount];
            
            cell = (UITableViewCell *)myCell;
        }
    } else {
        FloDefaultCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCellId forIndexPath:indexPath];
        
        switch (indexPath.section) {
            case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        myCell = [myCell setImage:[UIImage imageNamed:@"feedgroup_timeline_icon_message"] title:@"我的好友" detailTitle:nil];
                    } break;
                    case 1:
                    {
                        myCell = [myCell setImage:[UIImage imageNamed:@"surprise_picturebutton_highlighted"] title:@"我的相册" detailTitle:nil];
                    } break;
                    case 2:
                    {
                        myCell = [myCell setImage:[UIImage imageNamed:@"toolbar_icon_chat_vip"] title:@"我的收藏" detailTitle:[NSString stringWithFormat:@"%d",_userInfo.favouriteCount]];
                    } break;
                    case 3:
                    {
                        myCell = [myCell setImage:[UIImage imageNamed:@"more_weibo"] title:@"微博等级" detailTitle:[NSString stringWithFormat:@"Lv%d",_userInfo.userRank]];
                    }break;
                    default:
                        break;
                }
                
            } break;
            case 2:
            {
                if (indexPath.row == 0) {
                    myCell = [myCell setImage:[UIImage imageNamed:@"contact_miyou_icon"] title:@"感兴趣的人" detailTitle:nil];
                } else{
                    myCell = [myCell setImage:[UIImage imageNamed:@"contacts_findfriends_icon"] title:@"热门用户推荐" detailTitle:nil];
                }
            } break;
            default:
                break;
        }
        
        cell = (UITableViewCell *)myCell;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark - dealloc
- (void)dealloc
{
    // 移除定时器
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccess object:nil];
}


@end
