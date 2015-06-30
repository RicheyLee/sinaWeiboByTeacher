//
//  FloFollowUserCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/10.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloFollowUserCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FloUserInfo.h"

@implementation FloFollowUserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configContentWithUserinfo:(FloUserInfo *)userinfo
{
    [self.iconImageV sd_setImageWithURL:[NSURL URLWithString:userinfo.iconLargeURl]];
    self.nameL.text = userinfo.name;
    self.descriptionL.text = userinfo.userDescription;
}

@end
