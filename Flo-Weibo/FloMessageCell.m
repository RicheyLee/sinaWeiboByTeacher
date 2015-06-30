//
//  FloMessageCell.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/8.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloMessageCell.h"
#import "FloStatusModel.h"
#import "FloCommentsModel.h"
#import "FloUserInfo.h"
#import "comments.h"
#import "FloUtilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FloMessageCell

-(void)setContentWithStatus:(FloStatusModel *)status
{
    [self.userImageV sd_setImageWithURL:[NSURL URLWithString:status.user.userIconURL]];
    [self.userNameBtn setTitle:status.user.name forState:UIControlStateNormal];
    self.timeLabel.text = status.timeAgo;
    self.sourceLabel.text = status.source;
    self.textL.text = status.text;
    
    NSURL *url;
    if (status.pic_urls.count > 0) {
        NSDictionary *dic = (NSDictionary *)status.pic_urls[0];
        url = [NSURL URLWithString:dic[kStatusThumbnailPic]];
    } else if (status.reStatus.pic_urls.count > 0){
        NSDictionary *dic = (NSDictionary *)status.reStatus.pic_urls[0];
        url = [NSURL URLWithString:dic[kStatusThumbnailPic]];
    } else {
        url = [NSURL URLWithString:status.user.userIconURL];
    }
    [self.sourceImageV sd_setImageWithURL:url];
    
    self.sourceUserNameL.text = [NSString stringWithFormat:@"@%@",status.user.name];
    self.sourceTextL.text = status.text;
}

-(void)setcontentWithComments:(FloCommentsModel *)comments
{
    [self.userImageV sd_setImageWithURL:[NSURL URLWithString:comments.userInfo.iconLargeURl]];
    [self.userNameBtn setTitle:comments.userInfo.name forState:UIControlStateNormal];
    self.timeLabel.text = comments.time;
    self.sourceLabel.text = comments.source;
    self.textL.text = comments.commentsText;
    
    NSURL *url;
    if (comments.status.pic_urls.count > 0) {
        NSDictionary *dic = (NSDictionary *)comments.status.pic_urls[0];
        url = [NSURL URLWithString:dic[kStatusThumbnailPic]];
    } else if (comments.status.reStatus.pic_urls.count > 0){
        NSDictionary *dic = (NSDictionary *)comments.status.reStatus.pic_urls[0];
        url = [NSURL URLWithString:dic[kStatusThumbnailPic]];
    } else {
        url = [NSURL URLWithString:comments.status.user.userIconURL];
    }
    [self.sourceImageV sd_setImageWithURL:url];
    
    self.sourceUserNameL.text = [NSString stringWithFormat:@"@%@",comments.status.user.name];
    self.sourceTextL.text = comments.status.text;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
