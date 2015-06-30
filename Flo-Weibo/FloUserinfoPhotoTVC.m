//
//  FloUserinfoPhotoTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/12.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserinfoPhotoTVC.h"
#import "comments.h"
#import "FloAuthorization.h"
#import "AFNetworking.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FloUserInfo.h"
#import "FloStatusModel.h"
#import "FloUserInfoPhotoCell.h"
#import "SDPhotoBrowser.h"

@interface FloUserinfoPhotoTVC ()<SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, strong) NSArray *photoUrls;
@property (nonatomic) int dataCount;

@end

@implementation FloUserinfoPhotoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setLeftBarButtonItem];
    self.title = @"相册";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _statusArray = [NSMutableArray array];
    _dataCount = 0;
    [self addObserver:self forKeyPath:@"dataCount" options:NSKeyValueObservingOptionNew context:nil];
    
    [self requestStatusData];
    [self requestFavoriteData];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([change[@"new"] intValue] == 2) {
        [self configPhotoArrayWithStatuses:_statusArray];
    }
}

#pragma mark - request data
- (void)requestStatusData
{
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    [parameters setObject:[FloAuthorization sharedAuthorization].UID forKey:kUID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kUserStatusURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        NSMutableArray *statuses = [NSMutableArray array];
        NSArray *userStatuses = result[kStatusStatuses];
        for (NSDictionary *userStatus in userStatuses) {
            FloStatusModel *status = [[FloStatusModel alloc] initWithDictionary:userStatus];
            [statuses addObject:status];
        }
        [_statusArray addObjectsFromArray:statuses];
        self.dataCount += 1;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
    }];
}

//收藏的微博
- (void)requestFavoriteData
{
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kFavoriteListURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *favorites = responseObject[@"favorites"];
        NSMutableArray *favoriteStatus = [NSMutableArray array];
        for (NSDictionary *favoriteDic in favorites) {
            NSDictionary *statusDic = favoriteDic[@"status"];
            if (!statusDic[@"deleted"]) {
                FloStatusModel *status = [[FloStatusModel alloc] initWithDictionary:statusDic];
                [favoriteStatus addObject:status];
            }
        }
        [_statusArray addObjectsFromArray:favoriteStatus];
        self.dataCount += 1;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"网络错误"];
    }];
}

- (void)configPhotoArrayWithStatuses:(NSArray *)statuses
{
    NSMutableArray *mPhotoArray = [NSMutableArray array];
    for (FloStatusModel *status in statuses) {
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
    _photoUrls = mPhotoArray;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FloUserInfoPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];
    
    CGFloat width = self.view.frame.size.width;
    NSInteger rowNum = ceilf(_photoUrls.count / 3.0);
    for (int r = 0; r < rowNum; r++) {
        for (int c = 0; c < 3; c++) {
            if ((3 * r + c) < _photoUrls.count) {
                UIControl *imageControl = [[UIControl alloc] initWithFrame:CGRectMake(((width-40)/3+10) * c+10, ((width-40)/3+10) * r+10, (width-40)/3, (width-40)/3)];
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (width-40)/3, (width-40)/3)];
                [imageV sd_setImageWithURL:[NSURL URLWithString:_photoUrls[3 * r + c]]];
                [imageControl addSubview:imageV];
                [cell.contentView addSubview:imageControl];
                
                imageControl.tag = 3 * r + c + 1000;
                [imageControl addTarget:self action:@selector(imageControlAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    return cell;
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.view.frame.size.width;
    return (ceilf((float)_photoUrls.count / 3) * ((width-40)/3+10))+10;
}

#pragma mark - image browser
- (void)imageControlAction:(UIControl *)sender
{
    UIView *superV = sender.superview;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = superV; // 原图的父控件
    browser.imageCount = _photoUrls.count; // 图片总数
    browser.currentImageIndex = (int)sender.tag - 1000;
    browser.delegate = self;
    [browser show];
}


#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return nil;
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:_photoUrls[index]];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"dataCount"];
}

@end
