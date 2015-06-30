//
//  FloUserinfoFriendsTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/11.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserinfoFriendsTVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FloAuthorization.h"
#import "AFNetworking.h"
#import "comments.h"
#import "FloUserinfoFriendsCell.h"
#import "FloUtilities.h"
#import "FloUserInfo.h"

#define kFriendsCellID @"friendsCell"

static FloUserinfoFriendsCell *selectedCell;

@interface FloUserinfoFriendsTVC ()

@property (nonatomic, strong) NSMutableArray *userinfoArray;

@end

@implementation FloUserinfoFriendsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _userinfoArray = [NSMutableArray array];
    [self requestData];
    
    [self setLeftBarButtonItem];
    if ([_requestURL isEqualToString:kUserFriendsURL]) {
        self.title = @"我的好友";
    } else if ([_requestURL isEqualToString:kUserInterestedURL]){
        self.title = @"感兴趣的人";
    } else{
        self.title = @"热门用户";
    }
}

- (IBAction)followControlAction:(id)sender {
    selectedCell = (FloUserinfoFriendsCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:selectedCell];
    
    [self followOrNotCellIndexPath:indexPath];
}

- (void)setLeftBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButton)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)leftBarButton
{
    [self hiddenTabBar:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

#pragma mark - request data
- (void)requestData
{
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    if ([_requestURL isEqualToString:kUserFriendsURL]) {
        [parameters setObject:[FloAuthorization sharedAuthorization].UID forKey:kUID];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:_requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *resultArray = [NSMutableArray array];
        if ([_requestURL isEqualToString:kUserFriendsURL]) {
            NSArray *usersDicArray = responseObject[@"users"];
            for (NSDictionary *userDic in usersDicArray) {
                FloUserInfo *userInfo = [[FloUserInfo alloc] initWithDictionary:userDic];
                [resultArray addObject:userInfo];
            }
            _userinfoArray = resultArray;
            [self.tableView reloadData];
        } else if ([_requestURL isEqualToString:kUserInterestedURL]){
            NSArray *userArray = (NSArray *)responseObject;            
            for (NSDictionary *userIDDic in userArray) {
                NSString *uid = userIDDic[kUID];
                [resultArray addObject:uid];
            }
            [self requestUserinfoWithUids:resultArray];
        } else {
            NSArray *userArray = (NSArray *)responseObject;
            for (NSDictionary *userDic in userArray) {
                FloUserInfo *userinfo = [[FloUserInfo alloc] initWithDictionary:userDic];
                [resultArray addObject:userinfo];
            }
            _userinfoArray = resultArray;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
    }];
}

- (void)requestUserinfoWithUids:(NSArray *)uids
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    for (NSString *uid in uids) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     kUID:uid};
        [manager GET:kUsersShowURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            FloUserInfo *userInfo = [[FloUserInfo alloc] initWithDictionary:result];
            [_userinfoArray addObject:userInfo];
            
            if ([uid isEqualToString:[uids lastObject]]) {
                [self.tableView reloadData];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
        }];
    }
}

- (void)followOrNotCellIndexPath:(NSIndexPath *)indexPath
{
    NSString *promptStr;
    NSString *url;
    FloUserInfo *userinfo = _userinfoArray[indexPath.row];
    if (userinfo.isFollowing) {
        url = kCancelFollowUserURL;
        promptStr = @"取消关注";
    } else {
        url = kFollowUserURL;
        promptStr = @"关注";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{kAccessToken:[FloAuthorization sharedAuthorization].token,
                                 kUID:userinfo.idStr};
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([url isEqualToString:kCancelFollowUserURL]) {
            selectedCell.followImageV.image = [UIImage imageNamed:@"friendcircle_navigationbar_friendcircle"];
            userinfo.isFollowing = NO;
            [_userinfoArray replaceObjectAtIndex:indexPath.row withObject:userinfo];
        } else {
            selectedCell.followImageV.image = [UIImage imageNamed:@"friendcircle_popover_cell_friendcircle_highlighted"];
            userinfo.isFollowing = YES;
            [_userinfoArray replaceObjectAtIndex:indexPath.row withObject:userinfo];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@成功",promptStr]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@失败",promptStr]];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userinfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FloUserinfoFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsCellID forIndexPath:indexPath];
    
    FloUserInfo *userinfo = _userinfoArray[indexPath.row];
    [cell configContentWithUserinfo:userinfo];
    
    if (userinfo.isFollowing) {
        cell.followImageV.image = [UIImage imageNamed:@"friendcircle_popover_cell_friendcircle_highlighted"];
    } else {
        cell.followImageV.image = [UIImage imageNamed:@"friendcircle_navigationbar_friendcircle"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
@end
