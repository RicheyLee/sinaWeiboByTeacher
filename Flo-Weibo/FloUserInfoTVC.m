//
//  FloUserInfoTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/9.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserInfoTVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FloUserInfo.h"
#import "FloAuthorization.h"
#import "FloUserInfoHeaderV.h"
#import "AFNetworking.h"
#import "comments.h"
#import "FloAuthorizeVC.h"
#import "FloStatusModel.h"
#import "FloUserInfoHomeCell.h"
#import "FloUserInfoPhotoCell.h"
#import "FloHomeStatusCell.h"
#import "FloFollowUserCell.h"
#import "FloUtilities.h"
#import "FloStatusDetailVC.h"
#import "FloMeTVC.h"

@interface FloUserInfoTVC ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageV;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UILabel *friendsL;
@property (weak, nonatomic) IBOutlet UILabel *followerL;
@property (weak, nonatomic) IBOutlet UILabel *descriptionL;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageV;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageV;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (nonatomic)CGRect headerViewFrame;
@property (nonatomic, strong)FloUserInfoHeaderV *sectionHeaderView;

@property (nonatomic, strong) NSArray *statusArray;
@property (nonatomic, strong) NSArray *followingArray;
@property (nonatomic, strong) NSArray *photoURLArray;

@end

#define kUserinfoHomeCell   @"homeCell"
#define kUserinfoStatusCell @"statusCell"
#define kUserinfoPhotoCell  @"photoCell"
#define kUserinfoFollowCell @"followingUserCell"

#define kLoadDataTypeHome   @"loadDataHome"
#define kLoadDataTypeStatus @"loadDataStatus"
#define kLoadDataTypePhoto  @"loadDataPhoto"
static NSString *loadDataType;

@implementation FloUserInfoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerViewFrame = self.backgroundImageV.frame;
    
    [self setHeaderV];
    
    loadDataType = kLoadDataTypeStatus;
    [self requestDataURL:kUserStatusURL];
    
    self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
}

- (IBAction)swipeGestureAction:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIViewController *vc = self.navigationController.viewControllers.firstObject;
        if ([vc isKindOfClass:[FloMeTVC class]]) {
            [self hiddenTabBar:NO];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

- (void)setHeaderV
{
    self.sectionHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"FloUserInfoHeaderV" owner:nil options:nil] firstObject];
    [_sectionHeaderView.homeBtn addTarget:self action:@selector(sectionHeaderVBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_sectionHeaderView.statusBtn addTarget:self action:@selector(sectionHeaderVBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_sectionHeaderView.photoBtn addTarget:self action:@selector(sectionHeaderVBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundImageV.image = [UIImage imageNamed:@"img-2131165207.jpg"];
    
    //设置人物头像为圆形
    self.iconImageV.layer.cornerRadius = self.iconImageV.frame.size.height / 2;
    self.iconImageV.layer.borderWidth = 2.f;
    self.iconImageV.layer.masksToBounds = YES;
    self.iconImageV.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.3f].CGColor;
    [self.iconImageV sd_setImageWithURL:[NSURL URLWithString:_userInfo.iconLargeURl]];
    
    self.userNameL.text = _userInfo.name;
    self.followerL.text = [NSString stringWithFormat:@"粉丝 %d",_userInfo.followerCount];
    self.friendsL.text = [NSString stringWithFormat:@"关注 %d",_userInfo.followingCount];
    if (_userInfo.userDescription.length > 0) {
        self.descriptionL.text = [NSString stringWithFormat:@"简介：%@",_userInfo.userDescription];
    } else {
        self.descriptionL.text = @"暂无简介";
    }
    if ([_userInfo.sex isEqualToString:@"m"]) {
        self.sexImageV.image = [UIImage imageNamed:@"userinfo_icon_male"];
    } else if ([_userInfo.sex isEqualToString:@"f"]){
        self.sexImageV.image = [UIImage imageNamed:@"userinfo_icon_female"];
    }
    if (_userInfo.isVerified) {
        self.vipImageV.image = [UIImage imageNamed:@"common_icon_membership"];
    }
    
    if ([_userInfo.idStr isEqualToString:[FloAuthorization sharedAuthorization].UID]) {
        self.followBtn.hidden = YES;
    } else {
        if (_userInfo.isFollowing) {
            [self.followBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [self.followBtn setBackgroundColor:[UIColor lightGrayColor]];
        }
        [self.followBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - action
- (void)sectionHeaderVBtnAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1001:
        {
            loadDataType = kLoadDataTypeHome;
            if (_followingArray.count < 1) {
                [self requestDataURL:kFollowListURL];
            } else{
                [self.tableView reloadData];
            }
        } break;
        case 1002:
        {
            loadDataType = kLoadDataTypeStatus;
            [self.tableView reloadData];
        } break;
        case 1003:
        {
            loadDataType = kLoadDataTypePhoto;
            [self.tableView reloadData];
        } break;
        default:
            break;
    }
}

- (IBAction)restatusControlAction:(id)sender {
    // 点击转发的微博跳转到微博详情
    FloHomeStatusCell *cell = (FloHomeStatusCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    FloStatusModel *status = _statusArray[indexPath.row];
    FloStatusModel *repostStatus = status.reStatus;
    
    [self goStatusDetailVCWithStatus:repostStatus];
}

- (void)goStatusDetailVCWithStatus:(FloStatusModel *)status
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloStatusDetailVC *statusDetailVC = [storyboard instantiateViewControllerWithIdentifier:kStatusDetailVC];
    statusDetailVC.status = status;
    
    [self.navigationController pushViewController:statusDetailVC animated:YES];
}

- (void)followAction:(UIButton *)sender
{
    if (_userInfo.isFollowing) {
        [self followOrNotURL:kCancelFollowUserURL];
    } else {
        [self followOrNotURL:kFollowUserURL];
    }
}

//关注或取消关注
- (void)followOrNotURL:(NSString *)url
{
    FloAuthorization *authorization = [FloAuthorization sharedAuthorization];
    if (authorization.token) {
        NSString *promptStr;
        if ([url isEqualToString:kCancelFollowUserURL]) {
            promptStr = @"取消关注";
        } else {
            promptStr = @"关注";
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{kAccessToken:authorization.token,
                                     kUID:_userInfo.idStr};
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([url isEqualToString:kCancelFollowUserURL]) {
                [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
                [self.followBtn setBackgroundColor:[UIColor orangeColor]];
            } else {
                [self.followBtn setTitle:@"已关注" forState:UIControlStateNormal];
                [self.followBtn setBackgroundColor:[UIColor lightGrayColor]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@成功",promptStr]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@失败",promptStr]];
        }];
    } else {
        //未登录，转到登录页面
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FloAuthorizeVC *loginVC = [sb instantiateViewControllerWithIdentifier:kLoginVCIdentifier];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
}

#pragma mark - photo data
- (void)configPhotoArray
{
    NSMutableArray *mPhotoArray = [NSMutableArray array];
    for (FloStatusModel *status in _statusArray) {
        if (status.pic_urls.count > 0) {
            //将所有url取出
            NSArray *imageURLArray = [status.pic_urls valueForKeyPath:kStatusThumbnailPic];
            for (NSString *picUrl in imageURLArray) {
                
                [mPhotoArray addObject:picUrl];
            }
        } else if (status.reStatus.pic_urls > 0){
            //将所有url取出
            NSArray *imageURLArray = [status.reStatus.pic_urls valueForKeyPath:kStatusThumbnailPic];
            for (NSString *picUrl in imageURLArray) {
                [mPhotoArray addObject:picUrl];
            }
        }
    }
    
    _photoURLArray = mPhotoArray;
}

#pragma mark - request data
- (void)requestDataURL:(NSString *)urlStr
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    [parameters setObject:_userInfo.idStr forKey:kUID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        if ([urlStr isEqualToString:kFollowListURL]) {
            NSMutableArray *userArray = [NSMutableArray array];
            NSArray *followingUsers = result[@"users"];
            for (NSDictionary *userDic in followingUsers) {
                FloUserInfo *userInfo = [[FloUserInfo alloc] initWithDictionary:userDic];
                [userArray addObject:userInfo];
            }
            _followingArray = userArray;
        } else {
            NSMutableArray *statuses = [NSMutableArray array];
            NSArray *userStatuses = result[kStatusStatuses];
            for (NSDictionary *userStatus in userStatuses) {
                FloStatusModel *status = [[FloStatusModel alloc] initWithDictionary:userStatus];
                [statuses addObject:status];
            }
            _statusArray = statuses;
            
            // 根据微博数据提取图片
            [self configPhotoArray];
        }
        
        [self.tableView reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num = 0;
    if ([loadDataType isEqualToString:kLoadDataTypeHome]) {
        num = 2;
    } else{
        num = 1;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 0;
    if ([loadDataType isEqualToString:kLoadDataTypeHome]) {
        if (section == 0) {
            num = 1;
        } else {
            num = _followingArray.count;
        }
    } else if ([loadDataType isEqualToString:kLoadDataTypeStatus]){
        num = _statusArray.count;
    } else{
        num = 1;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if ([loadDataType isEqualToString:kLoadDataTypeHome]) {
        if (indexPath.section == 0) {
            FloUserInfoHomeCell *mycell = [tableView dequeueReusableCellWithIdentifier:kUserinfoHomeCell forIndexPath:indexPath];
            mycell.locationL.text = _userInfo.location;
            mycell.blogL.text = _userInfo.blogURL;
            NSDate *createDate = [FloUtilities dateWithDateString:_userInfo.createTime];
            mycell.createTimeL.text = [NSDateFormatter localizedStringFromDate:createDate dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
            
            cell = mycell;
        } else {
            FloFollowUserCell *mycell = [tableView dequeueReusableCellWithIdentifier:kUserinfoFollowCell forIndexPath:indexPath];
            [mycell configContentWithUserinfo:_followingArray[indexPath.row]];
            cell = mycell;
        }
    } else if ([loadDataType isEqualToString:kLoadDataTypeStatus]){
        FloHomeStatusCell *mycell = [tableView dequeueReusableCellWithIdentifier:kUserinfoStatusCell forIndexPath:indexPath];
        [mycell setContentWithStatus:_statusArray[indexPath.row]];
        
        cell = mycell;
    } else {
        FloUserInfoPhotoCell *mycell = [tableView dequeueReusableCellWithIdentifier:kUserinfoPhotoCell forIndexPath:indexPath];
        [mycell configContentWithPicUrls:_photoURLArray];
        
        cell = mycell;
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        for (int i = 1001; i < 1004; i++) {
            UIButton *btn = (UIButton *)[_sectionHeaderView viewWithTag:i];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        if ([loadDataType isEqualToString:kLoadDataTypeHome]) {
            [_sectionHeaderView.homeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        } else if ([loadDataType isEqualToString:kLoadDataTypeStatus]){
            [_sectionHeaderView.statusBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        } else {
            [_sectionHeaderView.photoBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        return self.sectionHeaderView;
    } else {
        CGFloat width = self.view.frame.size.width;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(8, -7, 100, 30)];
        lable.text = @"我的关注";
        lable.font = [UIFont systemFontOfSize:13];
        [view addSubview:lable];
        return view;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.sectionHeaderView.frame.size.height;
    } else{
        return 15;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([loadDataType isEqualToString:kLoadDataTypeHome]) {
        if (indexPath.section == 0) {
            return 88;
        } else {
            return 66;
        }
    } else if ([loadDataType isEqualToString:kLoadDataTypeStatus]){
        FloHomeStatusCell *mycell = [tableView dequeueReusableCellWithIdentifier:kUserinfoStatusCell];
        return [mycell cellHeight4StatusModel:_statusArray[indexPath.row]] + 5;
    } else {
        CGFloat width = self.view.frame.size.width;
        return (ceilf((float)_photoURLArray.count / 3) * ((width-40)/3+10))+10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kLoadDataTypeStatus) {
        FloStatusModel *status = _statusArray[indexPath.row];
        [self goStatusDetailVCWithStatus:status];
    }
}

#pragma mark - scroll view delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //如果小于0， 则扩大显示区域
    //增加的区域
    int offsetY = 0 - scrollView.contentOffset.y;
    
    CGRect frame = self.headerViewFrame;
    frame.size.height += offsetY;
    frame.origin.y -= offsetY;
    frame.size.width = self.view.frame.size.width;
    
    if (offsetY > 0) {
        self.backgroundImageV.frame = frame;
    }
}



@end
