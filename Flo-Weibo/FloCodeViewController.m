//
//  FloCodeViewController.m
//  Flo-Weibo
//
//  Created by qingyun on 15/5/6.
//  Copyright (c) 2015年 qingyun. All rights reserved.
//

#import "FloCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FloCodeResultVC.h"
#import "comments.h"

@interface FloCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)AVCaptureDevice *device;
@property (nonatomic, strong)AVCaptureDeviceInput *input;
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureMetadataOutput *output;//输出的是元数据

@property (nonatomic, weak)IBOutlet UIImageView *animationView;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)UIImageView *moveAnimationView;

@end

@implementation FloCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //添加一个图片qrcode_border
    UIImage *image = [UIImage imageNamed:@"qrcode_border"];
    //用图片的中心拉伸
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 26, 26)];
    [self.animationView setImage:image];
    
    //qrcode_scanline_qrcode
    UIImageView *moveView = [[UIImageView alloc] initWithFrame:self.animationView.bounds];
    self.moveAnimationView = moveView;
    [moveView setImage:[UIImage imageNamed:@"qrcode_scanline_qrcode"]];
    [self.animationView addSubview:self.moveAnimationView];
    self.animationView.clipsToBounds = YES;
    
    //构造timer，移动视图，产生动画
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(moveView) userInfo:nil repeats:YES];
}

-(void)moveView{
    self.moveAnimationView.frame = CGRectOffset(self.moveAnimationView.frame, 0, 5);
    if (self.moveAnimationView.frame.origin.y >= self.animationView.frame.size.height) {
        CGRect frame = self.moveAnimationView.frame;
        frame.origin.y = -self.animationView.frame.size.height;
        self.moveAnimationView.frame = frame;
    }
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self hiddenTabBar:NO];
}

- (void)hiddenTabBar:(BOOL)hidden
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarV object:[NSNumber numberWithBool:hidden]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //开启二维码扫描
    [self reading];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //停止二维码扫描
    [self stopRead];
}

-(BOOL)reading{
    
    //初始化device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = device;
    //初始化input
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    self.input = input;
    
    // 无设备时返回
    if (!self.input || error) {
        return NO;
    }
    
    //初始化session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    //连接session和input
    [self.session addInput:self.input];
    
    //初始化output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    self.output = output;
    
    //连接output和session
    [self.session addOutput:self.output];
    
    //指定output的delegate
    dispatch_queue_t queue = dispatch_queue_create("myqueue", NULL);
    [self.output setMetadataObjectsDelegate:self queue:queue];
    
    //指定output输出的元数据类型
    NSArray *types = [self.output availableMetadataObjectTypes];
    self.output.metadataObjectTypes = types;
    
    
    //初始化一个预览layer
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [layer setFrame:self.view.layer.bounds];
    layer.position  = self.view.center;
    [self.view.layer addSublayer:layer];
    
    //构造图片
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //整体是半透明
    CGContextSetRGBFillColor(context, 0, 0, 0, .3f);
    CGContextAddRect(context, self.view.bounds);
    CGContextFillPath(context);
    //中间不透明区域
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddRect(context, self.animationView.frame);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.bounds = self.view.bounds;
    maskLayer.position = self.view.center;
    maskLayer.contents = (__bridge id)(image.CGImage);
    
    layer.mask = maskLayer;
    
    [self.session startRunning];
    return YES;
}

-(void)stopRead{
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *object = metadataObjects.firstObject;
    
    // 传递结果到结果显示页面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FloCodeResultVC *codeResultVC = [storyboard instantiateViewControllerWithIdentifier:@"codeResultVC"];
    codeResultVC.codeInfo = [object stringValue];
    [self.navigationController pushViewController:codeResultVC animated:YES];
    
    [self performSelectorOnMainThread:@selector(stopRead) withObject:nil waitUntilDone:YES];
    
}

- (void)dealloc
{
    [self.timer invalidate];
}

@end
