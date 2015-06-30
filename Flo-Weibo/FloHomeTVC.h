//
//  FloHomeTVC.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class FloHomeStatusCell;
@class FloPromptView;
@class FloUpdatePromptV;

@interface FloHomeTVC : UITableViewController

@property (nonatomic, strong) NSArray *statusArray;

// 声明一个存计算cell高度的实例变量
@property (nonatomic, strong) FloHomeStatusCell *prototypeCell;

@property (nonatomic)BOOL requestLock;//yes 加锁

@property (nonatomic, strong) FloUpdatePromptV *updatePromptV;

-(void)reloadNew;

@property (nonatomic, strong) AVAudioPlayer *player;

@end
