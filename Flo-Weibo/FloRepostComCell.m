//
//  FloRepostComCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/7.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloRepostComCell.h"
#import "FloRepostModel.h"
#import "FloCommentsModel.h"
#import "FloUserInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FloRepostComCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentWithRepostModel:(FloRepostModel *)repostModel
{
    [self.nameBtn setTitle:repostModel.userInfo.name forState:UIControlStateNormal];
    self.timeLabel.text = repostModel.time;
    self.textL.text = repostModel.repostText;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:repostModel.userInfo.userIconURL]];
}

- (void)setContentWithCommentModel:(FloCommentsModel *)commentModel
{
    [self.nameBtn setTitle:commentModel.userInfo.name forState:UIControlStateNormal];
    self.timeLabel.text = commentModel.time;
    self.textL.text = commentModel.commentsText;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:commentModel.userInfo.userIconURL]];
}

@end
