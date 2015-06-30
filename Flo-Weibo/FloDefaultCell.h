//
//  FloDefaultCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloDefaultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView  *imageV;
@property (weak, nonatomic) IBOutlet UILabel      *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel      *detailLabel;

- (instancetype)setImage:(UIImage *)image title:(NSString *)title detailTitle:(NSString *)detailTitle;

@end
