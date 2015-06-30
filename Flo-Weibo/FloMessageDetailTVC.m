//
//  FloMessageDetailTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloMessageDetailTVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloStatusModel.h"
#import "FloCommentsModel.h"
#import "FloAuthorization.h"
#import "FloMessageCell.h"
#import "FloStatusDetailVC.h"
#import "FloSendMessageVC.h"
#import "FloUserInfoTVC.h"


@interface FloMessageDetailTVC ()

@property (nonatomic, strong) NSMutableArray *commentsArray;
@property (nonatomic, strong) NSMutableArray *statusArray;

@end

static NSString *requestURL;
static BOOL typeAtmeFirstRequest;

@implementation FloMessageDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLeftBarButtonItem];
    
    _commentsArray = [NSMutableArray array];
    _statusArray = [NSMutableArray array];
    
    if ([_VCType isEqualToString:kVCTypeAtme]) {
        typeAtmeFirstRequest = YES;
    }
    
    self.title = _titleStr;
    [self requestData];
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

// 回复评论
- (void)replyBtnAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
    sendMessageVC.requestURL = kReplyCommentsURL;
    sendMessageVC.titleStr = @"回复评论";
    
    FloMessageCell *cell = (FloMessageCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloCommentsModel *comments = _commentsArray[indexPath.section];
    sendMessageVC.statusID = comments.status.statusID;
    sendMessageVC.cid = comments.commentsID;
    
    [self presentViewController:sendMessageVC animated:YES completion:nil];
}

- (void)userNameAction:(id)sender
{
    FloMessageCell *cell = (FloMessageCell *)[[sender superview] superview];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloUserInfoTVC *userinfoTVC = [storyboard instantiateViewControllerWithIdentifier:kUserInfoTVC];
    FloUserInfo *userinfo;
    if ([_VCType isEqualToString:kVCTypeComment]) {
        FloCommentsModel *comModel = _commentsArray[indexPath.section];
        userinfo = comModel.userInfo;
    } else if (indexPath.section < _commentsArray.count){
        FloCommentsModel *comModel = _commentsArray[indexPath.section];
        userinfo = comModel.userInfo;
    } else {
        FloStatusModel *status = _statusArray[indexPath.section - _commentsArray.count];
        userinfo = status.user;
    }
    userinfoTVC.userInfo = userinfo;
    [self presentViewController:userinfoTVC animated:YES completion:nil];
}

- (void)statusControlAction:(id)sender
{
    FloMessageCell *cell = (FloMessageCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    FloStatusModel *status;
    if ([_VCType isEqualToString:kVCTypeComment]) {
        FloCommentsModel *comModel = _commentsArray[indexPath.section];
        status = comModel.status;
    } else if (indexPath.section < _commentsArray.count){
        FloCommentsModel *comModel = _commentsArray[indexPath.section];
        status = comModel.status;
    } else {
        status = _statusArray[indexPath.section - _commentsArray.count];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloStatusDetailVC *statusDetailVC = [storyboard instantiateViewControllerWithIdentifier:kStatusDetailVC];
    statusDetailVC.status = status;
    
    [self.navigationController pushViewController:statusDetailVC animated:YES];
}


#pragma mark - requestData
- (void)requestData
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    NSMutableDictionary *dic = [authorization requestParameters];
    if (!dic) {
        return;
    }
    
    if ([_VCType isEqualToString:kVCTypeComment]) {
        requestURL = kMessageCommentURL;
    } else if (typeAtmeFirstRequest){
        requestURL = kMessageComAtmeURL;
    } else {
        requestURL = kMessageStatusAtmeURL;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        
        if ([_VCType isEqualToString:kVCTypeComment]) {
            NSArray *comments = result[@"comments"];
            for (NSDictionary *dic in comments) {
                FloCommentsModel *comModel = [[FloCommentsModel alloc] initWithDictionary:dic];
                [_commentsArray addObject:comModel];
            }
            [self.tableView reloadData];
        } else if (typeAtmeFirstRequest){
            typeAtmeFirstRequest = NO;
            [self requestData];
            
            NSArray *comments = result[@"comments"];
            for (NSDictionary *dic in comments) {
                FloCommentsModel *comModel = [[FloCommentsModel alloc] initWithDictionary:dic];
                [_commentsArray addObject:comModel];
            }
        } else {
            NSArray *statuses = result[@"statuses"];
            for (NSDictionary *dic in statuses) {
                FloStatusModel *status = [[FloStatusModel alloc] initWithDictionary:dic];
                [_statusArray addObject:status];
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
        NSLog(@"消息详情页error>>>>%@",error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num = 0;
    if ([_VCType isEqualToString:kVCTypeComment]) {
        num = _commentsArray.count;
    } else {
        num = _commentsArray.count + _statusArray.count;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FloMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    
    if ([_VCType isEqualToString:kVCTypeComment]) {
        [cell setcontentWithComments:_commentsArray[indexPath.section]];
        // 评论可以回复
        [cell.replyBtn addTarget:self action:@selector(replyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    } else if (indexPath.section < _commentsArray.count){
        [cell setcontentWithComments:_commentsArray[indexPath.section]];
        // atme不可回复
        cell.replyBtn.hidden = YES;
    } else {
        [cell setContentWithStatus:_statusArray[indexPath.section-_commentsArray.count]];
        // atme不可回复
        cell.replyBtn.hidden = YES;
    }
    
    // 按钮事件
    [cell.userNameBtn addTarget:self action:@selector(userNameAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.ststusControl addTarget:self action:@selector(statusControlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FloMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    if ([_VCType isEqualToString:kVCTypeComment]) {
        [cell setcontentWithComments:_commentsArray[indexPath.section]];
    } else if (indexPath.section < _commentsArray.count){
        [cell setcontentWithComments:_commentsArray[indexPath.section]];
    } else {
        [cell setContentWithStatus:_statusArray[indexPath.section-_commentsArray.count]];
    }
    //计算出根据内容显示的区域
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}


@end
