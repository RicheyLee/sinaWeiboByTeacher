//
//  FloPostStatusWithPictureVC.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/13.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloPostStatusWithPictureVC.h"
#import "comments.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"

#define kPostURl @"https://upload.api.weibo.com/2/statuses/upload.json"

@interface FloPostStatusWithPictureVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarBtnItem;

@end

static BOOL isFirstLoad;

@implementation FloPostStatusWithPictureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rightBarBtnItem.enabled = NO;
    isFirstLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isFirstLoad) {
        if ([_pictureSource isEqualToString:kPicSourcePhotos]) {
            //进入图库选择图片
            [self selectAPictureFromPhotos];
        } else if ([_pictureSource isEqualToString:kPicSourceTakeAPhoto]){
            //拍摄照片
            [self takeAPhoto];
        } else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        return;
    }
}

- (void)selectAPictureFromPhotos
{
    UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
    imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  //选择图片类型
    imgPickerController.delegate = self;
    //模态切换到图片页面
    [self presentViewController:imgPickerController animated:YES completion:nil];
}

- (void)takeAPhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"该设备不支持拍照功能"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;  //选择图片类型
        imgPickerController.delegate = self;
        //模态切换到图片页面
        [self presentViewController:imgPickerController animated:YES completion:nil];
    }
}

#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{   // info 为返回的选取数据
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _imageV.image = image;
    //释放图库页面，返回原来的页面
    isFirstLoad = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)backBarAction:(id)sender {
    [self.textV resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendAction:(id)sender {
    if (_imageV.image) {
        [_textV resignFirstResponder];
        NSString *message = self.textV.text;
        if (message.length > 140) {
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"输入内容请不要超过140个汉字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertV show];
            return;
        }
        
        NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
        [parameters setObject:UIImagePNGRepresentation(_imageV.image) forKey:@"pic"];
        [parameters setObject:_textV.text forKey:@"status"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:kPostURl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"发布成功"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"发布失败"];
        }];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        return;
    }
}

- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_textV resignFirstResponder];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    _rightBarBtnItem.enabled = NO;
    
    return YES;
}

//当文本内容空时不能点击发送
- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] || textView.text == nil) {
        self.rightBarBtnItem.enabled = NO;
        return;
    } else {
        self.rightBarBtnItem.enabled = YES;
        return;
    }
}

#pragma mark - gesture delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (CGRectContainsPoint(_imageV.frame, point)) {
        [self selectAPictureFromPhotos];
    }
}

#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
