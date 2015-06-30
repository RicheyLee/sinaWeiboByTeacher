//
//  FloSendMessageVC.h
//  Flo-Weibo
//
//  Created by qingyun on 15/4/17.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FloSendMessageVC : UIViewController<UITextViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarBtnItem;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;

//API接口
@property (nonatomic, copy) NSString *requestURL;

// 微博可见性
@property (nonatomic, copy) NSString *statusVisible;

//请求参数：微博id...
@property (nonatomic, copy) NSString *statusID;

@property (nonatomic, copy) NSString *titleStr;

//回复评论参数
@property (nonatomic, copy) NSString *cid;  // 需要回复的评论id


@end
