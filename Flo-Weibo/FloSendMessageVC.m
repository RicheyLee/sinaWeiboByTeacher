//
//  FloSendMessageVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/4/17.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloSendMessageVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"

@implementation FloSendMessageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.requestURL) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    self.navigationTitle.title = _titleStr;
    self.rightBarBtnItem.enabled = NO;
}

- (IBAction)backAction:(id)sender {
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_textView resignFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    if ([_requestURL isEqualToString:kRepostStatusURL]) {
        self.rightBarBtnItem.enabled = YES;
    }
    
    return YES;
}

// 如果是发微博或评论，当文本内容空时不能点击发送
- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.requestURL isEqualToString:kRepostStatusURL]) {
        return;
    } else {
        if ([self.textView.text isEqualToString:@""] || self.textView.text == nil) {
            self.rightBarBtnItem.enabled = NO;
            return;
        } else {
            self.rightBarBtnItem.enabled = YES;
            return;
        }
    }
}

// inputAccessView


- (IBAction)sendMessage:(id)sender {
    // 构造请求参数
    NSString *message = self.textView.text;
    if (message.length > 140) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"输入内容请不要超过140个汉字" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    
    //回调结果
    NSString *promptStr;
    
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    if ([_requestURL isEqualToString:kUpdateStatusURL]) {
        [parameters setObject:message forKey:kStatus];
        
        if ([_statusVisible isEqualToString:@"2"]) {
            // 好友圈微博
            [parameters setObject:@"2" forKey:@"visible"];
        }
        
        promptStr = @"发微博";
    } else if ([_requestURL isEqualToString:kRepostStatusURL]){
        // 转发，内容可为空
        if (![self.textView.text isEqualToString:@""] && self.textView.text != nil) {
            [parameters setObject:message forKey:kStatus];
        }
        [parameters setObject:_statusID forKey:@"id"];
        promptStr = @"转发微博";
    } else if ([_requestURL isEqualToString:kCommentStatusURl]){
        [parameters setObject:message forKey:@"comment"];
        [parameters setObject:_statusID forKey:@"id"];
        promptStr = @"评论";
    } else if ([_requestURL isEqualToString:kReplyCommentsURL]){
        [parameters setObject:message forKey:@"comment"];
        [parameters setObject:_statusID forKey:@"id"];
        [parameters setObject:_cid forKey:@"cid"];
        promptStr = @"回复评论";
    } else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"请求URL错误"];
        return;
    }
    
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    [manger POST:_requestURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@成功",promptStr]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:[NSString stringWithFormat:@"%@失败",promptStr]];
    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}



@end
