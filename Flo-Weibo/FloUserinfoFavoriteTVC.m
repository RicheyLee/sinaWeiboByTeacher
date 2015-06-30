//
//  FloUserinfoFavoriteTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/11.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserinfoFavoriteTVC.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"
#import "FloHomeStatusCell.h"
#import "FloStatusModel.h"
#import "comments.h"
#import "FloSendMessageVC.h"
#import "FloHomeStatusFooterCell.h"
#import "FloStatusDetailVC.h"
#import "FloUserInfoTVC.h"

#define kStatusCellID    @"statusCell"
#define kFooterCellID    @"footerCell"

static FloHomeStatusCell *cancelFavoriteStatusCell;

@interface FloUserinfoFavoriteTVC ()

@property (nonatomic, strong) NSMutableArray *favoriteStatuses;

@end

@implementation FloUserinfoFavoriteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    _favoriteStatuses = [NSMutableArray array];
    [self setLeftBarButtonItem];
    
    [self requestData];
    self.title = @"我的收藏";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelFavoriteSuccess) name:kCancelFavoriteSuccess object:nil];
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

- (void)cancelFavoriteSuccess
{

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cancelFavoriteStatusCell];
    [_favoriteStatuses removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark - request data
- (void)requestData
{
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kFavoriteListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *favorites = responseObject[@"favorites"];
        for (NSDictionary *favoriteDic in favorites) {
            NSDictionary *statusDic = favoriteDic[@"status"];
            if (!statusDic[@"deleted"]) {
                FloStatusModel *status = [[FloStatusModel alloc] initWithDictionary:statusDic];
                [_favoriteStatuses addObject:status];
            }
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
    }];
}


#pragma mark - action
- (IBAction)cancelFavoriteAction:(id)sender {
    // 取出点击了按钮的单元格
    cancelFavoriteStatusCell = (FloHomeStatusCell *)[[sender superview] superview];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"取消收藏该条微博?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (IBAction)restatusControlAction:(id)sender {
    // 点击转发的微博跳转到微博详情
    FloHomeStatusCell *cell = (FloHomeStatusCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloStatusModel *status = _favoriteStatuses[indexPath.row];
    FloStatusModel *repostStatus = status.reStatus;
    
    [self goStatusDetailVCWithStatus:repostStatus];
}

- (IBAction)nameBtnAction:(id)sender {
    FloHomeStatusCell *cell = (FloHomeStatusCell *)[[sender superview] superview];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloUserInfoTVC *userinfoTVC = [storyboard instantiateViewControllerWithIdentifier:kUserInfoTVC];
    FloStatusModel *status = (FloStatusModel *)_favoriteStatuses[indexPath.row];
    userinfoTVC.userInfo = status.user;
    [self presentViewController:userinfoTVC animated:YES completion:nil];
}

- (void)goStatusDetailVCWithStatus:(FloStatusModel *)status
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloStatusDetailVC *statusDetailVC = [storyboard instantiateViewControllerWithIdentifier:kStatusDetailVC];
    statusDetailVC.status = status;
    
    [self.navigationController pushViewController:statusDetailVC animated:YES];
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cancelFavoriteStatusCell];
        FloStatusModel *favoriteStatus = _favoriteStatuses[indexPath.row];
        NSString *statusID = favoriteStatus.statusID;
        [FloStatusModel cancelFavoriteStatus:statusID];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _favoriteStatuses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FloHomeStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatusCellID forIndexPath:indexPath];
    [cell setContentWithStatus:_favoriteStatuses[indexPath.row]];
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FloHomeStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatusCellID];
    return [cell cellHeight4StatusModel:_favoriteStatuses[indexPath.row]]+5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FloStatusModel *status = _favoriteStatuses[indexPath.row];
    [self goStatusDetailVCWithStatus:status];
}

@end
