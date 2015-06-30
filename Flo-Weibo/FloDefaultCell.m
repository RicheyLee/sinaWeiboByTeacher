//
//  FloDefaultCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloDefaultCell.h"

@implementation FloDefaultCell

- (instancetype)setImage:(UIImage *)image title:(NSString *)title detailTitle:(NSString *)detailTitle
{
    self.imageV.image = image;
    self.titleLabel.text = title;
    self.detailLabel.text = detailTitle;
    return self;
}

@end
