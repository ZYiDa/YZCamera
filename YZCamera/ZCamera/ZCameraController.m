//
//  ViewController.m
//  自定义相机
//
//  Created by YYKit on 2017/7/11.
//  Copyright © 2017年 kzkj. All rights reserved.
//

#import "ZCameraController.h"
#import <AVFoundation/AVFoundation.h>

#import <CoreMotion/CoreMotion.h>
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ZCameraController ()
{
    UIButton *change;
    UIButton *takePhoto;
    UIButton *backBtn;
    NSInteger direction;
}
@property (nonatomic,strong) AVCaptureDevice *devides;
@property (nonatomic,strong) AVCaptureDeviceInput *input;//输入设备
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;//输出图片
@property (nonatomic,strong) AVCaptureSession *session;//会话
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;//预览层

@property (nonatomic, strong) CMMotionManager * motionManager;
@end

@implementation ZCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCamera];
}

#pragma mark 初始化相关对象
- (void)initCamera
{
    self.devides = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.devides error:nil];
    self.imageOutput = [[AVCaptureStillImageOutput alloc]init];
    self.session  = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;

    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput])
    {
        [self.session addOutput:self.imageOutput];
    }

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    [self.session startRunning];


    self.previewImage = [UIImage imageNamed:@"face2"];
    CALayer *faceRectLayer = [CALayer new];
    faceRectLayer.zPosition = 1;
    faceRectLayer.frame = CGRectMake(0, 0, WIDTH, HEIGHT );
    faceRectLayer.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:0].CGColor;
    faceRectLayer.contents = (__bridge id _Nullable)(self.previewImage.CGImage);
    [self.previewLayer addSublayer:faceRectLayer];

    change = [UIButton buttonWithType:UIButtonTypeCustom];
    [change setBackgroundImage:[UIImage imageNamed:@"切换"] forState:UIControlStateNormal];
    [change addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:change];


    takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhoto setBackgroundImage:[UIImage imageNamed:@"拍照"] forState:UIControlStateNormal];
    [takePhoto addTarget:self action:@selector(selectedToTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhoto];

    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"下拉"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(selectedToDismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    change.frame = CGRectMake(0, 0, 40, 40);
    takePhoto.frame = CGRectMake(0, 0, 60, 60);
    backBtn.frame = CGRectMake(0, 0, 40,40);

    change.center = CGPointMake(WIDTH - 60, HEIGHT - 60);
    takePhoto.center = CGPointMake(WIDTH/2, HEIGHT - 60);
    backBtn.center = CGPointMake(60, HEIGHT - 60);}

#pragma mark 返回上一界面
- (void)selectedToDismiss
{
    [self dismissVC];
}

#pragma mark dismiss
- (void)dismissVC
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.session stopRunning];
        [_motionManager stopDeviceMotionUpdates];
    }];
}

#pragma mark 切换前后相机
- (void)changeCamera
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1)
    {
        NSError *error;

        /**添加切换时的翻转动画**/
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";

        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;

        /**获取另外一个摄像头的位置**/
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            self.session.sessionPreset = AVCaptureSessionPreset1280x720;
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            self.session.sessionPreset = AVCaptureSessionPreset1280x720;
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }

        /**生成新的输入**/
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil)
        {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput])
            {
                [self.session addInput:newInput];
                self.input = newInput;

            }
            else
            {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];

        }
        else if (error)
        {
            NSLog(@"Change carema failed.Error:%@", error);
        }
    }
}

#pragma mark 拍照
- (void)selectedToTakePhoto
{
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion)
    {
        NSLog(@"拍照失败!");
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (imageDataSampleBuffer == nil)
         {
             return ;
         }
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

         UIImage *image = [UIImage imageWithData:imageData];
         if (image == nil)
         {
             return;
         }

//         if (![self.titleString isEqualToString:@"人脸图像"])
//         {
//             self.takePhotoImage([RoteImage image:image rotation:direction]);
//         }
//         else
//         {
             self.takePhotoImage(image,direction);

//         }
         [self dismissVC];
     }];
}

#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{

    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
        {
            return device;
        }
    return nil;
}

- (void)selectedToGetThePhotoImageWithBlock:(GetThePhotoImage)takePhotoImage
{
    self.takePhotoImage = takePhotoImage;
}

- (void)dealloc
{
    if ([self.session isRunning])
    {
        [self.session stopRunning];
        [_motionManager stopDeviceMotionUpdates];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
