//
//  FloIconCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloIconCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel     *userName;
@property (weak, nonatomic) IBOutlet UIImageView *vipView;
@property (weak, nonatomic) IBOutlet UILabel     *detailLabel;

@end
