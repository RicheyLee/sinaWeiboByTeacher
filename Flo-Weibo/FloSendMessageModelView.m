//
//  FloSendMessageModelView.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/2.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloSendMessageModelView.h"
#import "FloBtnControl.h"
#import "FloTabBarController.h"
#import "comments.h"

#define kBtnWidth  110
#define kBtnHeight 110
#define kVSpace    20

static CGFloat width;
static CGFloat height;

@implementation FloSendMessageModelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        width = [UIScreen mainScreen].bounds.size.width;
        height = [UIScreen mainScreen].bounds.size.height;
        
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIImageView *backGroundImageV = [[UIImageView alloc] initWithFrame:CGRectMake((width-154)/2, 80, 154, 48)];
        backGroundImageV.image = [UIImage imageNamed:@"compose_slogan"];
        [self addSubview:backGroundImageV];
        
        self.btnView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 2*width, 2*kBtnHeight+kVSpace)];
        
        NSArray *line1Labels = @[@"文字", @"相册", @"拍摄", @"好友圈", @"秒拍", @"音乐"];
        NSArray *line2Labels = @[@"签到", @"点评", @"更多", @"长微博", @"收款"];
        NSArray *labels = @[line1Labels, line2Labels];
        
        NSArray *line1ImageNames = @[@"tabbar_compose_idea", @"tabbar_compose_photo", @"tabbar_compose_camera", @"tabbar_compose_friend", @"tabbar_compose_shooting", @"tabbar_compose_music"];
        NSArray *line2ImageNames = @[@"tabbar_compose_lbs", @"tabbar_compose_review", @"tabbar_compose_more", @"tabbar_compose_weibo", @"tabbar_compose_transfer"];
        NSArray *images = @[line1ImageNames, line2ImageNames];
        
        for (int l=0; l<2; l++) {
            for (int c=0; c<6; c++) {
                FloBtnControl *btnControl;
                if (c<3) {
                    btnControl = [[FloBtnControl alloc] initWithFrame:CGRectMake((width-3*kBtnWidth)/2+kBtnWidth*c, kBtnHeight*l, kBtnWidth, kBtnHeight)];
                } else {
                    btnControl = [[FloBtnControl alloc] initWithFrame:CGRectMake(width+(width-3*kBtnWidth)/2+kBtnWidth*(c-3), kBtnHeight*l, kBtnWidth, kBtnHeight)];
                }
                
                // 第二行与第一行间距20
                if (l == 1) {
                    CGRect rect = btnControl.frame;
                    rect.origin.y = rect.origin.y+20;
                    btnControl.frame = rect;
                }
                
                if (l == 1 && c == 5) {
                    btnControl = nil;
                } else {
                    btnControl.imageV.image = [UIImage imageNamed:images[l][c]];
                    btnControl.textL.text = labels[l][c];
                    btnControl.tag = _btnView.subviews.count+1000;
                    [btnControl addTarget:self action:@selector(btnControlAction:) forControlEvents:UIControlEventTouchUpInside];
                    [btnControl addTarget:self action:@selector(btnTransform:) forControlEvents:UIControlEventTouchDown];
                    [_btnView addSubview:btnControl];
                }
            }
        }
        
        self.tabBarV = [[UIView alloc] initWithFrame:CGRectMake(0, height-69, width, 49)];
        _tabBarV.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, _tabBarV.frame.size.width, _tabBarV.frame.size.height);
        [cancelBtn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_close"] forState:UIControlStateNormal];
        cancelBtn.tag = 1001;
        [cancelBtn addTarget:self action:@selector(modelVCancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_tabBarV addSubview:cancelBtn];
        
        [self addSubview:_btnView];
        [self addSubview:_tabBarV];
    }
    
    return self;
}

- (void)btnControlAction:(FloBtnControl *)btnControl
{
    // 松开按钮后复原
    btnControl.transform = CGAffineTransformMakeScale(1, 1);
    
    if (btnControl.tag == 1008) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_return"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarV addSubview:backBtn];
        
        UIButton *cancelBtn = (UIButton *)[self.tabBarV viewWithTag:1001];
        
        CGRect rect = self.btnView.frame;
        rect.origin.x = -width;
        [UIView animateWithDuration:0.25 animations:^{
            self.btnView.frame = rect;
            
            backBtn.frame = CGRectMake(0, 0, width/2, 49);
            cancelBtn.frame = CGRectMake(width/2, 0, width/2, 49);
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBtnControlBeTouched object:btnControl];
    }
}

- (void)btnTransform:(FloBtnControl *)sender
{
    // 按下时放大
    sender.transform = CGAffineTransformMakeScale(1.2, 1.2);
}

- (void)backAction:(UIButton *)sender
{
    UIButton *cancelBtn = (UIButton *)[self.tabBarV viewWithTag:1001];
    
    CGRect rect = self.btnView.frame;
    rect.origin.x = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.btnView.frame = rect;
        
        [sender removeFromSuperview];
        cancelBtn.frame = CGRectMake(0, 0, width, 49);
    }];
}

- (void)modelVCancelAction
{
    CGRect rect = self.btnView.frame;
    rect.origin.y = height;
    [UIView animateWithDuration:0.25 animations:^{
        self.btnView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
}
*/

@end
