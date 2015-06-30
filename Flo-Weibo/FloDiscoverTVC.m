//
//  FloDiscoverTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/19.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloDiscoverTVC.h"
#import "FloAuthorization.h"
#import "FloAuthorizeVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloStatusModel.h"
#import "FloDatabaseEngin.h"
#import "FloHomeStatusCell.h"
#import "FloHomeStatusFooterCell.h"
#import "FloPromptView.h"
#import "FloUpdatePromptV.h"
#import "FloSendMessageVC.h"
#import "FloStatusDetailVC.h"
#import "FloUserInfoTVC.h"

#define kPublicStatusTableName @"publicstatus"
#define kStatusCellID          @"statusCell"
#define kFooterCellID          @"footerCell"


#define kStaticToken @"2.00Pzc3BDK7RYnC0610a5d15f82tOGD"
//#define kStaticToken @"2.00B4VDGGK7RYnC144938651etz9SXE"

static FloHomeStatusCell *favoriteStatusCell;

@implementation FloDiscoverTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置提示音
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"msgcome" withExtension:@"wav"];
    AVAudioPlayer *splayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    splayer.volume = 1.0;
    self.player = splayer;
    
    self.statusArray = [FloDatabaseEngin selectPublicStatusFromDatabase];
    
    // 设置提示框
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.updatePromptV = [[FloUpdatePromptV alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
    //实现下拉刷新。UIRefreshControl
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    self.refreshControl = control;
    //添加触发事件
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
    self.requestLock = NO;
    [self loadData];
}

#pragma mark - action
- (IBAction)statusMoreAction:(id)sender {
    // 取出点击了按钮的单元格
    favoriteStatusCell = (FloHomeStatusCell *)[[sender superview] superview];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"收藏该条微博?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"收藏", nil];
    [alertView show];
}

- (IBAction)repostStatusAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
    sendMessageVC.requestURL = kRepostStatusURL;
    sendMessageVC.titleStr = @"转发微博";
    
    FloHomeStatusFooterCell *footerCell = (FloHomeStatusFooterCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:footerCell];
    FloStatusModel *status = _statusArray[indexPath.section];
    sendMessageVC.statusID = status.statusID;
    
    [self presentViewController:sendMessageVC animated:YES completion:nil];
}

- (IBAction)commentStatusAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
    sendMessageVC.requestURL = kCommentStatusURl;
    sendMessageVC.titleStr = @"评论";
    
    FloHomeStatusFooterCell *footerCell = (FloHomeStatusFooterCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:footerCell];
    FloStatusModel *status = _statusArray[indexPath.section];
    sendMessageVC.statusID = status.statusID;
    
    [self presentViewController:sendMessageVC animated:YES completion:nil];
}

- (IBAction)reatatusAction:(id)sender {
    // 点击转发的微博跳转到微博详情
    FloHomeStatusCell *cell = (FloHomeStatusCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloStatusModel *status = _statusArray[indexPath.section];
    FloStatusModel *repostStatus = status.reStatus;
    
    [self goStatusDetailVCWithStatus:repostStatus];
}

- (IBAction)nameBtnAction:(id)sender {
    FloHomeStatusCell *cell = (FloHomeStatusCell *)[[sender superview] superview];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloUserInfoTVC *userinfoTVC = [storyboard instantiateViewControllerWithIdentifier:kUserInfoTVC];
    FloStatusModel *status = (FloStatusModel *)_statusArray[indexPath.section];
    userinfoTVC.userInfo = status.user;
    [self presentViewController:userinfoTVC animated:YES completion:nil];
}

- (void)goStatusDetailVCWithStatus:(FloStatusModel *)status
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloStatusDetailVC *statusDetailVC = [storyboard instantiateViewControllerWithIdentifier:kStatusDetailVC];
    statusDetailVC.status = status;
    
    [self hiddenTabBar:YES];
    [self.navigationController pushViewController:statusDetailVC animated:YES];
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:favoriteStatusCell];
        FloStatusModel *favoriteStatus = _statusArray[indexPath.section];
        NSString *statusID = favoriteStatus.statusID;
        [FloStatusModel favoriteStatus:statusID];
    }
}


#pragma mark - 请求微博数据
- (void)loadData
{
    if (!self.requestLock) {
        self.requestLock= YES;
    }else{
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:kStaticToken forKey:kAccessToken];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://api.weibo.com/2/statuses/public_timeline.json" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray *status = result[kStatusStatuses];
        NSMutableArray *statusModels = [NSMutableArray array];
        
        //停止下拉刷新
        [self.refreshControl endRefreshing];
        //取出新的数据
        FloStatusModel *firstStatus = [_statusArray firstObject];
        NSInteger firstStatusID = [firstStatus.statusID integerValue];
        for (NSDictionary *statusInfo in status) {
            FloStatusModel *statusModel = [[FloStatusModel alloc] initWithDictionary:statusInfo];
            NSInteger statusid = [statusModel.statusID integerValue];
            if (statusid > firstStatusID) {
                [statusModels addObject:statusModel];
            }
        }
        // 显示更新提示框
        [self loadUpdatePromptVWithNumber:statusModels.count];
        //将原有的追加到新的数组中
        [statusModels addObjectsFromArray:_statusArray];
        self.statusArray = statusModels;
        
        //更新UI
        [self.tableView reloadData];
        // 保存微博到数据库
        [FloDatabaseEngin saveStatus2Table:kPublicStatusTableName status:status];
        
        //解锁
        self.requestLock= NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"公共请求微博错误:%@",error);
        [self.refreshControl endRefreshing];
        self.requestLock = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


- (void)loadUpdatePromptVWithNumber:(NSUInteger)num
{
    if (num < 1) {
        return;
    } else {
        //播放声音
        [_player play];
        
        self.updatePromptV.label.text = [NSString stringWithFormat:@"%ld 条新微博",num];
        [self.view addSubview:_updatePromptV];
        [self performSelector:@selector(removePromptV) withObject:nil afterDelay:2];
    }
}

- (void)removePromptV
{
    [self.updatePromptV removeFromSuperview];
}

#pragma mark - TableView datasource delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _statusArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        FloHomeStatusCell *myCell = [tableView dequeueReusableCellWithIdentifier:kStatusCellID forIndexPath:indexPath];
        [myCell setContentWithStatus:_statusArray[indexPath.section]];
        cell = myCell;
    } else {
        FloHomeStatusFooterCell *myCell = [tableView dequeueReusableCellWithIdentifier:kFooterCellID forIndexPath:indexPath];
        [myCell setValueWithStatus:_statusArray[indexPath.section]];
        cell = myCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FloStatusModel *status = _statusArray[indexPath.section];
    [self goStatusDetailVCWithStatus:status];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row == 0) {
        FloHomeStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatusCellID];
        height = [cell cellHeight4StatusModel:_statusArray[indexPath.section]]+5;
    } else {
        height = 25;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}


#pragma mark - method
- (void)goLoginVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloAuthorizeVC *loginVC = [storyboard instantiateViewControllerWithIdentifier:kLoginVCIdentifier];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)setRightBarBtnItem
{
    UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"登陆" style:UIBarButtonItemStyleDone target:self action:@selector(goLoginVC)];
    self.navigationItem.rightBarButtonItem = rightBarBtnItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    if (authorization.token) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self setRightBarBtnItem];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}


@end
