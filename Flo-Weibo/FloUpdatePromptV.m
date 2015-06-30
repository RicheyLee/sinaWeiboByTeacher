//
//  FloUpdatePromptV.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/6.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUpdatePromptV.h"

@implementation FloUpdatePromptV

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor orangeColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.textColor = [UIColor whiteColor];
    
    [self addSubview:_label];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
