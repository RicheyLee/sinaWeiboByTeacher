//
//  FloAboutVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/13.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloAboutVC.h"

@interface FloAboutVC ()

@end

@implementation FloAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setLeftBarButtonItem];
}

- (void)setLeftBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButton)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)leftBarButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
