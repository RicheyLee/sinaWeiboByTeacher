//
//  FloHomeStatusFooterCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/1.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloHomeStatusFooterCell.h"
#import "FloStatusModel.h"

@implementation FloHomeStatusFooterCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setValueWithStatus:(FloStatusModel *)status
{
    [self.retweet setTitle:[NSString stringWithFormat:@" %ld",status.reposts_count] forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@" %ld",status.comments_count] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
