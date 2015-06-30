//
//  FloTabBarController.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FloAuthorization;
@class FloBtnControl;
@class FloSendMessageModelView;
@class FloPromptView;

@interface FloTabBarController : UITabBarController

@property (nonatomic, strong) FloAuthorization *authorization;

@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) FloSendMessageModelView *modelView;

@property (nonatomic, strong) FloPromptView *promptView;

@end
