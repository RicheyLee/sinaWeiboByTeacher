//
//  FloTabBarController.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/18.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloTabBarController.h"
#import "comments.h"
#import "FloAuthorizeVC.h"
#import "FloAuthorization.h"
#import "FloSendMessageVC.h"
#import "FloSendMessageModelView.h"
#import "FloBtnControl.h"
#import "FloHomeTVC.h"
#import "FloPromptView.h"
#import "FloPostStatusWithPictureVC.h"
#import "FloPostStatusWithLocation.h"

static CGFloat width;
static CGFloat height;

@implementation FloTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    // 消息提示框
    self.promptView = [[FloPromptView alloc] initWithFrame:CGRectMake((width-100)/2, height-120, 100, 40)];
    
    // 设置tabBar
    [self configTabBarView];
    
    // 通过token判断用户是否登陆，从而设置显示哪个页面
    self.authorization = [FloAuthorization sharedAuthorization];
    if (_authorization.token) {
        // 已登陆,显示首页
        self.selectedIndex = 0;
        UIButton *btn = (UIButton *)[_tabBarView viewWithTag:1000];
        btn.selected = YES;

        NSLog(@"TabBarC's token:%@",_authorization.token);
    } else {
        // 未登陆,显示发现
        self.selectedIndex = 2;
        UIButton *btn = (UIButton *)[_tabBarView viewWithTag:1003];
        btn.selected = YES;
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:kLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnControlTouched:) name:kBtnControlBeTouched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenTabBarV:) name:kHiddenTabBarV object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPrompt:) name:kShowPrompt object:nil];
}

#pragma mark - tabBar
- (void)configTabBarView
{
    self.tabBar.hidden = YES;
    self.tabBar.translucent = YES;
    
    self.tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, height-49, width, 49)];
    self.tabBarView.backgroundColor = self.tabBar.backgroundColor;
    
    NSArray *imageNames = @[@"tabbar_home", @"tabbar_message_center", @"3", @"tabbar_discover", @"tabbar_profile"];
    NSArray *selectImageNames = @[@"tabbar_home_selected", @"tabbar_message_center_selected", @"3", @"tabbar_discover_selected", @"tabbar_profile_selected"];
    NSArray *btnTitles = @[@"首页", @"信息", @"3", @"发现", @"我"];
    
    for (int i=0; i<5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*width/5, 0, width/5, 49);
        if (i == 2) {
            UIImage *image = [self sendMessageVCItemImage];
            [btn setImage:image forState:UIControlStateNormal];
        } else {
            [btn setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:selectImageNames[i]] forState:UIControlStateSelected];
            NSAttributedString *attributedStr =  [[NSAttributedString alloc] initWithString:btnTitles[i] attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            [btn setAttributedTitle:attributedStr forState:UIControlStateNormal];
            
            NSAttributedString *selectedAttributedStr =  [[NSAttributedString alloc] initWithString:btnTitles[i] attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor], NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            [btn setAttributedTitle:selectedAttributedStr forState:UIControlStateSelected];
            
            // 设置按钮图片与文字位置
            switch (i) {
                case 0:
                {
                    btn.titleEdgeInsets = UIEdgeInsetsMake(30, -11, 0, 0);
                    btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 32, 0, 0);
                }
                    break;
                case 1:
                case 3:
                {
                    btn.titleEdgeInsets = UIEdgeInsetsMake(30, -33, 0, 0);
                    btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 20, 0, 0);
                }
                    break;
                case 4:
                {
                    btn.titleEdgeInsets = UIEdgeInsetsMake(30, -42, 0, 0);
                    btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
                }
                    break;
                default:
                    break;
            }
            
        }
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if (btn.tag == 1000) {
            [btn addTarget:self action:@selector(homeBtnTouchAgain) forControlEvents:UIControlEventTouchDownRepeat];
        }
        [self.tabBarView addSubview:btn];
    }
    UIView *topV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    topV.backgroundColor = [UIColor lightGrayColor];
    [_tabBarView addSubview:topV];
    [self.view addSubview:_tabBarView];
}

- (void)btnAction:(UIButton *)button
{
    if (button.tag == 1002) {
        self.modelView = [[FloSendMessageModelView alloc] initWithFrame:CGRectMake(0, 20, width, height-20)];
        [self.view addSubview:_modelView];
        CGRect rect = _modelView.btnView.frame;
        rect.origin.x = 0;
        _modelView.btnView.frame = rect;
        rect.origin.y = 250;
        [UIView animateWithDuration:0.25 animations:^{
            _modelView.btnView.frame = rect;
        }];
    } else if (button.tag > 1002){
        self.selectedIndex = button.tag-1001;
        
        for (int i=1000; i<1005; i++) {
            UIButton *btn = (UIButton *)[_tabBarView viewWithTag:i];
            btn.selected = NO;
        }
        button.selected = YES;
    } else {
        self.selectedIndex = button.tag-1000;
        
        for (int i=1000; i<1005; i++) {
            UIButton *btn = (UIButton *)[_tabBarView viewWithTag:i];
            btn.selected = NO;
        }
        button.selected = YES;
    }
}

- (UIImage *)sendMessageVCItemImage
{
    CGSize size = CGSizeMake(56, 40);
    // 创建了一个位图上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    // 获取该位图上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor orangeColor].CGColor);
    
    // 先绘制背景
    const CGPoint points[] = {0, 0, size.width, 0, size.width, size.height, 0, size.height};
    CGContextAddLines(ctx, points, 4);
    CGContextFillPath(ctx);
    
    // 再绘制中间的加号
    CGContextMoveToPoint(ctx, 15, 20);
    CGContextAddLineToPoint(ctx, 41, 20);
    CGContextMoveToPoint(ctx, 28, 7);
    CGContextAddLineToPoint(ctx, 28, 33);
    CGContextStrokePath(ctx);
    
    // 从当前位图上下文中，取出当前画布上的图片
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Login/notification
- (void)login
{
    // 从storyboard中取出登陆视图,模态切换到登陆页面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloAuthorizeVC *loginVC = [storyboard instantiateViewControllerWithIdentifier:kLoginVCIdentifier];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)loginSuccess:(NSNotification *)noti
{
    self.authorization = noti.object;
    self.tabBarView.hidden = NO;
    
    self.promptView.label.text = @"登陆成功";
    [self.view addSubview:_promptView];
    [self performSelector:@selector(removePromptV) withObject:nil afterDelay:2];
    
    // 登陆成功跳转首页
    self.selectedIndex = 0;
    for (int i=1001; i<1005; i++) {
        UIButton *btn = (UIButton *)[_tabBarView viewWithTag:i];
        btn.selected = NO;
    }
    UIButton *button = (UIButton *)[_tabBarView viewWithTag:1000];
    button.selected = YES;
}

- (void)loginOut
{
    self.selectedIndex = 2;
    for (int i=1001; i<1005; i++) {
        UIButton *btn = (UIButton *)[_tabBarView viewWithTag:i];
        btn.selected = NO;
    }
    UIButton *button = (UIButton *)[_tabBarView viewWithTag:1003];
    button.selected = YES;
    [self login];
}

- (void)homeBtnTouchAgain
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHomeBtnTouchAgain object:nil];
}

- (void)showPrompt:(NSNotification *)noti
{
    self.promptView.label.text = noti.object;
    [self.view addSubview:_promptView];
    [self performSelector:@selector(removePromptV) withObject:nil afterDelay:2];
}

- (void)removePromptV
{
    [self.promptView removeFromSuperview];
}

- (void)btnControlTouched:(NSNotification *)noti
{
    [self.modelView removeFromSuperview];
    if (_authorization.token) {
        FloBtnControl *btnControl = noti.object;
        switch (btnControl.tag) {
            case 1000:
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
                sendMessageVC.requestURL = kUpdateStatusURL;
                sendMessageVC.titleStr = @"发微博";
                
                [self presentViewController:sendMessageVC animated:YES completion:nil];
            } break;
            case 1001:
            {
                // 相册
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloPostStatusWithPictureVC *statusWithPicVC = [storyboard instantiateViewControllerWithIdentifier:kPostStatusWithPicVC];
                statusWithPicVC.pictureSource = kPicSourcePhotos;
                
                [self presentViewController:statusWithPicVC animated:YES completion:nil];
            } break;
            case 1002:
            {
                // 拍照片
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloPostStatusWithPictureVC *statusWithPicVC = [storyboard instantiateViewControllerWithIdentifier:kPostStatusWithPicVC];
                statusWithPicVC.pictureSource = kPicSourceTakeAPhoto;
                
                [self presentViewController:statusWithPicVC animated:YES completion:nil];
            } break;
            case 1003:
            {
                // 好友圈微博
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
                sendMessageVC.requestURL = kUpdateStatusURL;
                sendMessageVC.titleStr = @"发微博";
                sendMessageVC.statusVisible = @"2";
                
                [self presentViewController:sendMessageVC animated:YES completion:nil];
            } break;
            case 1004:
            {
                // 拍视频
            } break;
            case 1005:
            {
                // 音乐
            } break;
            case 1006:
            {
                // 签到
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloPostStatusWithLocation *statusWithLocVC = [storyboard instantiateViewControllerWithIdentifier:kPostStatusWithLocVC];
                [self presentViewController:statusWithLocVC animated:YES completion:nil];
            } break;
            case 1007:
            {
                // 点评
            } break;
            case 1009:
            {
                // 长微博
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FloSendMessageVC *sendMessageVC = [storyboard instantiateViewControllerWithIdentifier:kSendMessageVC];
                sendMessageVC.requestURL = kUpdateStatusURL;
                sendMessageVC.titleStr = @"发微博";
                
                [self presentViewController:sendMessageVC animated:YES completion:nil];
            } break;
            case 1010:
            {
                // 收款
            } break;
            default:
                break;
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"请先登录"];
        return;
    }
}

- (void)hiddenTabBarV:(NSNotification *)noti
{
    self.tabBarView.hidden = [noti.object boolValue];;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBtnControlBeTouched object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHiddenTabBarV object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowPrompt object:nil];
}

@end
