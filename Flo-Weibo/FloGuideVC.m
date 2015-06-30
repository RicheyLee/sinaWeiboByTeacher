//
//  FloGuideVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/25.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloGuideVC.h"
#import "FloVCManager.h"

#define kWidth self.view.frame.size.width
#define kHeight self.view.frame.size.height

@interface FloGuideVC ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FloGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(kWidth*4, kHeight);
    
    for (int i = 0; i < 4; i++) {
        CGRect imageFrame = CGRectMake(i*kWidth, 0, kWidth, kHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        NSString *imageName = [NSString stringWithFormat:@"new_feature_%d",i+1];
        imageView.image = [UIImage imageNamed:imageName];
        [self.scrollView addSubview:imageView];
    }
    
    UIButton *go = [UIButton buttonWithType:UIButtonTypeCustom];
    go.frame = CGRectMake(kWidth*3, kHeight-100, kWidth, 44);
    [go setTitle:@">>>>GO" forState:UIControlStateNormal];
    [go setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [go addTarget:self action:@selector(guideEnd) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:go];
}

- (void)guideEnd
{
    [FloVCManager guideEnd];
}

@end
