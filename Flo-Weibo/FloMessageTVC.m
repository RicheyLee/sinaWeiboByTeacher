//
//  FloMessageTVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloMessageTVC.h"
#import "FloFirstCell.h"
#import "FloSecondCell.h"
#import "comments.h"
#import "FloMessageDetailTVC.h"

#define kFirstIdentifier @"firstCell"
#define kSecondIdentifier @"secondCell"

@implementation FloMessageTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}


- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FloMessageDetailTVC *messadeDetailVC = [sb instantiateViewControllerWithIdentifier:kMessageDetailVC];
            messadeDetailVC.VCType = kVCTypeAtme;
            messadeDetailVC.titleStr = @"所有微博";
            
            [self hiddenTabBar:YES];
            [self.navigationController pushViewController:messadeDetailVC animated:YES];
        } break;
        case 1:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FloMessageDetailTVC *messadeDetailVC = [sb instantiateViewControllerWithIdentifier:kMessageDetailVC];
            messadeDetailVC.VCType = kVCTypeComment;
            messadeDetailVC.titleStr = @"所有评论";
            
            [self hiddenTabBar:YES];
            [self.navigationController pushViewController:messadeDetailVC animated:YES];
        } break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row < 2) {
        FloFirstCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:kFirstIdentifier forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
            {
                myCell.icon.image = [UIImage imageNamed:@"messagescenter_at"];
                myCell.label.text = @"@我的";
            } break;
            case 1:
            {
                myCell.icon.image = [UIImage imageNamed:@"messagescenter_comments"];
                myCell.label.text = @"评论";
            } break;
            default:
                break;
        }
        cell = (UITableViewCell *)myCell;
    } else {
        FloSecondCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:kSecondIdentifier forIndexPath:indexPath];
        
        myCell.icon.image = [UIImage imageNamed:@"messagescenter_comments"];
        myCell.detailImageV.image = [UIImage imageNamed:@"tabbar_home"];
        myCell.timeLabel.text = @"15-04-17";
        myCell.label.text = @"一个用户";
        myCell.detailLabel.text = @"介绍";
        
        cell = (UITableViewCell *)myCell;
    }
    return cell;
}

@end
