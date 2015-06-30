//
//  FloStatusDetailVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/7.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloStatusDetailVC.h"
#import "FloAuthorization.h"
#import "FloCommentsModel.h"
#import "FloRepostModel.h"
#import "AFNetworking.h"
#import "comments.h"
#import "FloRepostComCell.h"
#import "FloHomeStatusCell.h"
#import "FloStatusModel.h"
#import "FloRepostComCellHeaderV.h"
#import "FloMessageDetailTVC.h"
#import "FloSendMessageVC.h"
#import "FloHomeTVC.h"
#import "FloDiscoverTVC.h"
#import "FloUserInfoTVC.h"


#define kStatusCellIdentifier @"statusCell"
#define kRepostComCellIdentifier @"repostCommentCell"

#define kCommentDataSource @"commentDataSource"
#define kRepostDataSource  @"repostDataSource"

@interface FloStatusDetailVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FloRepostComCellHeaderV *headerV;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *currentDataSource;

@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSMutableArray *repostArray;

@end

static BOOL isFirstLoad;

@implementation FloStatusDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 默认显示评论列表
    isFirstLoad = YES;
    self.currentDataSource = kRepostDataSource;
    self.commentArray = [NSMutableArray array];
    self.repostArray = [NSMutableArray array];
    
    [self setHeaderV];
    
    // 导航栏
    [self setLeftBarButtonItem];
    
    [self requestData];
    
    //底栏
    [self configTabBarV];
}

#pragma mark - 底部转发与评论
- (void)configTabBarV
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, height-104, width, 44)];
    footerV.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UIButton *repostBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    repostBtn.frame = CGRectMake(0, 0, width/2-1, 43);
    [repostBtn setImage:[UIImage imageNamed:@"statusdetail_icon_retweet"] forState:UIControlStateNormal];
    [repostBtn setTitle:@" 转发" forState:UIControlStateNormal];
    [repostBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [repostBtn addTarget:self action:@selector(repostAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *spaceV = [[UIView alloc] initWithFrame:CGRectMake(width/2-1, 12, 1, 20)];
    spaceV.backgroundColor = [UIColor lightGrayColor];
    UIView *topV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    topV.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(width/2, 0, width/2, 43);
    [commentBtn setImage:[UIImage imageNamed:@"statusdetail_icon_comment"] forState:UIControlStateNormal];
    [commentBtn setTitle:@" 评论" forState:UIControlStateNormal];
    [commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(commentAction) forControlEvents:UIControlEventTouchUpInside];
    [footerV addSubview:topV];
    [footerV addSubview:commentBtn];
    [footerV addSubview:spaceV];
    [footerV addSubview:repostBtn];
    [self.view addSubview:footerV];
}

- (void)repostAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
    sendMessageVC.requestURL = kRepostStatusURL;
    sendMessageVC.titleStr = @"转发微博";
    sendMessageVC.statusID = self.status.statusID;
    
    [self presentViewController:sendMessageVC animated:YES completion:nil];
}

- (void)commentAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
    sendMessageVC.requestURL = kCommentStatusURl;
    sendMessageVC.titleStr = @"评论";
    sendMessageVC.statusID = self.status.statusID;
    
    [self presentViewController:sendMessageVC animated:YES completion:nil];
}


- (void)setHeaderV
{
    self.headerV = [[[NSBundle mainBundle] loadNibNamed:@"FloRepostComCellHeaderV" owner:nil options:nil] firstObject];
    [self.headerV.repostBtn addTarget:self action:@selector(repostBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerV.commentBtn addTarget:self action:@selector(commentBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)repostBtn:(id)sender
{
    _currentDataSource = kRepostDataSource;
    [self requestData];
    
    [self.headerV.repostBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.headerV.commentBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)commentBtn:(id)sender
{
    _currentDataSource = kCommentDataSource;
    [self requestData];
    
    [self.headerV.repostBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.headerV.commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)setLeftBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButton)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)leftBarButton
{
    NSArray *VCArray = self.navigationController.viewControllers;
    if ([VCArray[VCArray.count-2] isKindOfClass:[FloHomeTVC class]] || [VCArray[VCArray.count-2] isKindOfClass:[FloDiscoverTVC class]]) {
        [self hiddenTabBar:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}
- (IBAction)nameAction:(id)sender {
    FloRepostComCell *cell = (FloRepostComCell *)[[sender superview] superview];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloUserInfoTVC *userinfoTVC = [storyboard instantiateViewControllerWithIdentifier:kUserInfoTVC];
    FloCommentsModel *comModel = (FloCommentsModel *)_commentArray[indexPath.row];
    userinfoTVC.userInfo = comModel.userInfo;
    [self presentViewController:userinfoTVC animated:YES completion:nil];
}

- (IBAction)statusNameAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloUserInfoTVC *userinfoTVC = [storyboard instantiateViewControllerWithIdentifier:kUserInfoTVC];
    userinfoTVC.userInfo = _status.user;
    [self presentViewController:userinfoTVC animated:YES completion:nil];
}

- (void)requestData
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    NSMutableDictionary *dic = [authorization requestParameters];
    if (!dic) {
        return;
    }
    [dic setObject:_status.statusID forKey:kCommontID];

    NSString *requestURL;
    if ([_currentDataSource isEqualToString:kRepostDataSource]) {
        requestURL = kShowRepostURl;
    } else {
        requestURL = kShowCommentsURL;
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        
        if ([_currentDataSource isEqualToString:kCommentDataSource]) {
            NSArray *comments = result[@"comments"];
            [_commentArray removeAllObjects];
            for (NSDictionary *comDic in comments) {
                FloCommentsModel *comModel = [[FloCommentsModel alloc] initWithDictionary:comDic];
                [_commentArray addObject:comModel];
            }
            [_headerV.commentBtn setTitle:[NSString stringWithFormat:@"评论%@",result[@"total_number"]] forState:UIControlStateNormal];
        } else {
            [_headerV.repostBtn setTitle:[NSString stringWithFormat:@"转发%@",result[@"total_number"]] forState:UIControlStateNormal];
            
            //接口问题，reposts为空
            NSArray *reposts = result[@"reposts"];
            [_repostArray removeAllObjects];
            for (NSDictionary *repost in reposts) {
                FloRepostModel *repostModel = [[FloRepostModel alloc] initWithDictionary:repost];
                [_repostArray addObject:repostModel];
            }
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        
        // 第一次加载时同时请求转发，评论数量
        if (isFirstLoad) {
            isFirstLoad = NO;
            _currentDataSource = kCommentDataSource;
            [self requestData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
        NSLog(@"%@",error);
    }];
    
}



#pragma tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FloHomeStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatusCellIdentifier];
        
        //取出要显示的数据
        return [cell cellHeight4StatusModel:_status]+5;
    }else{
        FloRepostComCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepostComCellIdentifier];
        //要计算的model
        if ([_currentDataSource isEqualToString:kCommentDataSource]) {
            // 评论
            [cell setContentWithCommentModel:_commentArray[indexPath.row]];
        } else {
            // 转发
            [cell setContentWithRepostModel:_repostArray[indexPath.row]];
        }
        //计算出根据内容显示的区域
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    if (section == 0) {
        height = 5;
    } else {
        height = 40;
    }
    return height;
}

#pragma tableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        FloHomeStatusCell *mycell = [tableView dequeueReusableCellWithIdentifier:kStatusCellIdentifier forIndexPath:indexPath];
        [mycell setContentWithStatus:_status];
        
        cell = mycell;
    } else {
        // 评论或转发列表
        FloRepostComCell *mycell = [tableView dequeueReusableCellWithIdentifier:kRepostComCellIdentifier forIndexPath:indexPath];
        
        if ([_currentDataSource isEqualToString:kCommentDataSource]) {
            // 评论
            [mycell setContentWithCommentModel:_commentArray[indexPath.row]];
            cell = mycell;
        } else {
            // 转发
            [mycell setContentWithRepostModel:_repostArray[indexPath.row]];
            cell = mycell;
        }
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (section == 0) {
        num = 1;
    } else {
        if ([_currentDataSource isEqualToString:kCommentDataSource]) {
            num = _commentArray.count;
        } else {
            num = _repostArray.count;
        }
    }
    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return _headerV;
    } else {
        return nil;
    }
}


@end
