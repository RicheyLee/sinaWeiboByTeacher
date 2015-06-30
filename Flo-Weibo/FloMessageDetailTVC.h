//
//  FloMessageDetailTVC.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kVCTypeAtme @"atme"
#define kVCTypeComment @"comment"

@interface FloMessageDetailTVC : UITableViewController

@property (nonatomic, copy) NSString *titleStr;

// 视图类型
@property (nonatomic) NSString *VCType;

@end
