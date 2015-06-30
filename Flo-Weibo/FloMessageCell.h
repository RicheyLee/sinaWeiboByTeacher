//
//  FloMessageCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloStatusModel;
@class FloCommentsModel;

@interface FloMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageV;
@property (weak, nonatomic) IBOutlet UIButton *userNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UILabel *textL;

@property (weak, nonatomic) IBOutlet UIControl *ststusControl;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageV;
@property (weak, nonatomic) IBOutlet UILabel *sourceUserNameL;
@property (weak, nonatomic) IBOutlet UILabel *sourceTextL;

// 提到我的微博
- (void)setContentWithStatus:(FloStatusModel *)status;

// 提到我的评论
- (void)setcontentWithComments:(FloCommentsModel *)comments;


@end
