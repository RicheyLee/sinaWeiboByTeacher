//
//  FloMeTVC.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloUserInfo;

@interface FloMeTVC : UITableViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) FloUserInfo      *userInfo;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL requestLock;

@end
