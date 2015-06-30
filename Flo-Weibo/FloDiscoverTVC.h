//
//  FloDiscoverTVC.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/19.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class FloHomeStatusCell;
@class FloPromptView;
@class FloUpdatePromptV;

@class FloAuthorization;

@interface FloDiscoverTVC : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *statusArray;

@property (nonatomic)BOOL requestLock;//yes 加锁

@property (nonatomic, strong) FloUpdatePromptV *updatePromptV;

@property (nonatomic, strong) AVAudioPlayer *player;

@end
