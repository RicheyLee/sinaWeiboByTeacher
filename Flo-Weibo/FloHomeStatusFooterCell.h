//
//  FloHomeStatusFooterCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/1.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloStatusModel;

@interface FloHomeStatusFooterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *retweet;
@property (weak, nonatomic) IBOutlet UIButton *comment;

- (void)setValueWithStatus:(FloStatusModel *)status;

@end
