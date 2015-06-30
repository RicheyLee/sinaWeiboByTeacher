//
//  FloHomeTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloHomeTVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"
#import "FloStatusModel.h"
#import "FloDatabaseEngin.h"
#import "FloHomeStatusCell.h"
#import "FloHomeStatusFooterCell.h"
#import "FloPromptView.h"
#import "FloUpdatePromptV.h"
#import "FloCodeViewController.h"
#import "FloSendMessageVC.h"
#import "FloStatusDetailVC.h"
#import "FloUserinfoFriendsTVC.h"
#import "FloUserInfoTVC.h"

#define kFriendsTVC      @"friendsTVC"
#define kStatusTableName @"status"
#define kStatusCellID    @"statusCell"
#define kFooterCellID    @"footerCell"
#define kLoaddata        @"loaddata"
#define kLoadNew         @"loadNew"
#define kLoadMore        @"loadMore"

static NSString *loaddataType;
static FloHomeStatusCell *favoriteStatusCell;

@implementation FloHomeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",NSHomeDirectory());
    
    //设置提示音
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:@"msgcome" withExtension:@"wav"];
    AVAudioPlayer *splayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    splayer.volume = 1.0;
    self.player = splayer;
    
    // 设置提示框
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.updatePromptV = [[FloUpdatePromptV alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    
    //实现下拉刷新。UIRefreshControl
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    self.refreshControl = control;
    //添加触发事件
    [self.refreshControl addTarget:self action:@selector(reloadNew) forControlEvents:UIControlEventValueChanged];
    
    // 初始化prototypeCell
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kStatusCellID];
    
    // 先加载本地微博
    self.statusArray = [FloDatabaseEngin selectStatusFromDatabase];
    
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    [self setTitle];
    self.requestLock = NO;
    // 请求最新微博
    if (authorization.token) {
        loaddataType = kLoadNew;
        [self reloadNew];
    }
    
    
    // 登陆成功时接收数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNew) name:kHomeBtnTouchAgain object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutResetHomeVC) name:kLoginOut object:nil];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
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

- (IBAction)codeAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     FloCodeViewController *codeVC = [storyboard instantiateViewControllerWithIdentifier:@"codeVC"];
    [self.navigationController pushViewController:codeVC animated:YES];
    
    [self hiddenTabBar:YES];
}

- (IBAction)addUserAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloUserinfoFriendsTVC *friendsTVC = [sb instantiateViewControllerWithIdentifier:kFriendsTVC];
    friendsTVC.requestURL = kUserHotURL;
    [self hiddenTabBar:YES];
    [self.navigationController pushViewController:friendsTVC animated:YES];
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
    
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    NSMutableDictionary *dic = [authorization requestParameters];
    if (!dic) {
        [self.refreshControl endRefreshing];
        self.requestLock = NO;
        return;
    }
    
    // 根据不同请求类型构造参数
    if ([loaddataType isEqualToString:kLoadNew] && self.statusArray.count != 0) {
        [dic setObject:[self.statusArray.firstObject statusID] forKey:@"since_id"];
    } else if ([loaddataType isEqualToString:kLoadMore] && self.statusArray.count != 0){
        NSInteger statusID = [[self.statusArray.lastObject statusID] integerValue];
        statusID -= 1;
        NSNumber *statusIDObj = [NSNumber numberWithInteger:statusID];
        [dic setObject:statusIDObj forKey:@"max_id"];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kHomeStatusesURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray *status = result[kStatusStatuses];
        
        NSMutableArray *statusModels = [NSMutableArray arrayWithCapacity:status.count];
        for (NSDictionary *statusInfo in status) {
            // 初始化model
            FloStatusModel *statusModel = [[FloStatusModel alloc] initWithDictionary:statusInfo];
            [statusModels addObject:statusModel];
        }
        
        if ([loaddataType isEqualToString:kLoaddata]) {
            self.statusArray = statusModels;
        } else if ([loaddataType isEqualToString:kLoadNew]){
            //将原有的追加到新的数组中
            [statusModels addObjectsFromArray:self.statusArray];
            self.statusArray = statusModels;
            //停止下拉刷新
            [self.refreshControl endRefreshing];
            // 显示更新提示框
            [self loadUpdatePromptVWithNumber:status.count];
        } else if ([loaddataType isEqualToString:kLoadMore]){
            //追加到原有数组中
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.statusArray];
            [array addObjectsFromArray:statusModels];
            self.statusArray = array;
        }
        
        //更新UI
        [self.tableView reloadData];
        // 保存微博到数据库
        [FloDatabaseEngin saveStatus2Table:kStatusTableName status:status];
        
        //解锁
        self.requestLock= NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"首页请求微博错误:%@",error);
        [self.refreshControl endRefreshing];
        self.requestLock = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (void)reloadNew
{
    loaddataType = kLoadNew;
    [self loadData];
}

- (void)reloadMore
{
    loaddataType = kLoadMore;
    [self loadData];
}

#pragma mark - notification

- (void)loginSuccess
{
    [self setTitle];
    [self loadData];
}

- (void)logoutResetHomeVC
{
    [self setTitle];
    self.statusArray = nil;
    [self.tableView reloadData];
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

- (void)setTitle
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    NSString *userID = authorization.UID;
    if (userID) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",userID]];
        
        // 如果用户信息已存在，直接取出设置title
        // 如果本地信息不存在，网络请求用户信息
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSDictionary *userInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
            self.title = userInfoDic[kScreenName];
        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{kAccessToken:authorization.token,
                                         kUID:authorization.UID};
            [manager GET:kUsersShowURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *result = (NSDictionary *)responseObject;
                self.title = result[kScreenName];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"请求用户信息错误：%@",error);
            }];
        }

    } else {
        self.title = @"微博";
    }
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据将要显示的cell，判断剩余的未刷新的cell个数
    NSInteger count =  self.statusArray.count - (indexPath.section + 1);
    if (count == 5) {
        //满足加载更多的条件
        [self reloadMore];
    }
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
        FloHomeStatusCell *cell = self.prototypeCell;
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHomeBtnTouchAgain object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOut object:nil];
}

@end
