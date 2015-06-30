//
//  FloUserInfoPhotoCell.h
//  Flo-Weibo
//
//  Created by qingyun on 15/5/10.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FloUserInfoPhotoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imageSuperV;

- (void)configContentWithPicUrls:(NSArray *)picUrls;

@end
