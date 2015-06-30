//
//  FloPostStatusWithLocation.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/13.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloPostStatusWithLocation.h"
#import "AFNetworking.h"
#import "FloAuthorization.h"
#import "comments.h"
#import <CoreLocation/CoreLocation.h>

@interface FloPostStatusWithLocation ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet UILabel *locationL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarBtnItem;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D coord;

@end

@implementation FloPostStatusWithLocation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rightBarBtnItem.enabled = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_textV resignFirstResponder];
    }
}

- (IBAction)backAction:(id)sender {
    [self.textV resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postStatusAction:(id)sender {
    // 构造请求参数
    NSString *message = self.textV.text;
    if (message.length > 140) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"输入内容请不要超过140个汉字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertV show];
        return;
    }
    
    NSMutableDictionary *parameters = [[FloAuthorization sharedAuthorization] requestParameters];
    //设置location：lat纬度，long经度
    if (_coord.latitude) {
        [parameters setObject:[NSNumber numberWithFloat:_coord.latitude] forKey:@"lat"];
        [parameters setObject:[NSNumber numberWithFloat:_coord.longitude] forKey:@"long"];
    } else {
        NSLog(@"定位服务不可用");
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    [manger POST:kUpdateStatusURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"发布成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPrompt object:@"发布失败"];
    }];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
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

#pragma mark - location delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *lastLocation = [locations lastObject];
    self.coord = lastLocation.coordinate;
    self.locationL.text = [NSString stringWithFormat:@"%@ 经度:%f 纬度:%f",_locationL.text, _coord.longitude, _coord.latitude];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
}

@end
