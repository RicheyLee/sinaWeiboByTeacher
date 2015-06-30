//
//  FloPromptView.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/6.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloPromptView.h"

@implementation FloPromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:15];
    
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
