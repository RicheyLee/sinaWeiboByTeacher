//
//  FloUserInfoPhotoCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/10.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloUserInfoPhotoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FloUserInfoPhotoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configContentWithPicUrls:(NSArray *)picUrls
{
    CGFloat width = self.frame.size.width;
    
    int rowNum = ceilf((float)picUrls.count / 3);
    for (int r = 0; r < rowNum; r++) {
        for (int c = 0; c < 3; c++) {
            if ((3 * r + c) == picUrls.count) {
                return;
            } else {
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(((width-40)/3+10) * c+10, ((width-40)/3+10) * r+10, (width-40)/3, (width-40)/3)];
                [imageV sd_setImageWithURL:[NSURL URLWithString:picUrls[3 * r + c]]];
                [self addSubview:imageV];
            }
        }
    }
}

@end
