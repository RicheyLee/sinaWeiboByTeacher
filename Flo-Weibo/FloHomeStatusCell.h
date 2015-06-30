//
//  FloHomeStatusCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/30.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloStatusModel;

@interface FloHomeStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *IconImageV;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImageV;
@property (weak, nonatomic) IBOutlet UIButton    *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *levelImagev;
@property (weak, nonatomic) IBOutlet UILabel     *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel     *source;
@property (weak, nonatomic) IBOutlet UILabel     *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel     *statusText;
@property (weak, nonatomic) IBOutlet UIControl   *retweetBackControl;
@property (weak, nonatomic) IBOutlet UILabel     *retweetedLabel;

@property (weak, nonatomic) IBOutlet UIView *statusImageSuperV;
@property (weak, nonatomic) IBOutlet UIView *restatusImageSuperV;


- (void)setContentWithStatus:(FloStatusModel *)status;
-(CGFloat)cellHeight4StatusModel:(FloStatusModel *)status;

@end
