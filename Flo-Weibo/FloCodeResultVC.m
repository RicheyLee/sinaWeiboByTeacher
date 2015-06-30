//
//  FloCodeResultVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/6.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloCodeResultVC.h"
#import "comments.h"

@interface FloCodeResultVC ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation FloCodeResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.resultLabel.text = _codeInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self hiddenTabBar:NO];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}


@end
