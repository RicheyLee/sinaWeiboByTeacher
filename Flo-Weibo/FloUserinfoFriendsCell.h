//
//  FloUserinfoFriendsCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/11.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloUserInfo;

@interface FloUserinfoFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *descriptionL;
@property (weak, nonatomic) IBOutlet UIControl *followControl;
@property (weak, nonatomic) IBOutlet UIImageView *followImageV;

- (void)configContentWithUserinfo:(FloUserInfo *)userinfo;

@end
