//
//  FloRepostComCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/7.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloCommentsModel;
@class FloRepostModel;

@interface FloRepostComCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *textL;

- (void)setContentWithCommentModel:(FloCommentsModel *)commentModel;
- (void)setContentWithRepostModel:(FloRepostModel *)repostModel;

@end
