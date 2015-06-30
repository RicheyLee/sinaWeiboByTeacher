//
//  FloFollowUserCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/10.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloUserInfo;

@interface FloFollowUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *descriptionL;

- (void)configContentWithUserinfo:(FloUserInfo *)userinfo;

@end
