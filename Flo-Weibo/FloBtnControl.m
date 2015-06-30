//
//  FloBtnControl.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/2.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloBtnControl.h"

@implementation FloBtnControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 80, 80)];
        self.textL = [[UILabel alloc] initWithFrame:CGRectMake(0, 89, 110, 21)];
        self.textL.textColor = [UIColor darkGrayColor];
        self.textL.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_imageV];
        [self addSubview:_textL];
    }
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
