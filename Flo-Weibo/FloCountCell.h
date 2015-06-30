//
//  FloCountCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloCountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *weiboCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;

@end
