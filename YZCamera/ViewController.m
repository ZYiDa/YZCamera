//
//  ViewController.m
//  YZCamera
//
//  Created by YYKit on 2017/7/19.
//  Copyright © 2017年 kzkj. All rights reserved.
//

#import "ViewController.h"
#import "ZCameraController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectedToTakePhoto:(id)sender
{
    __weak typeof(self) weakSelf = self;
    ZCameraController *zCamera = [ZCameraController new];
    [zCamera selectedToGetThePhotoImageWithBlock:^(UIImage *image, NSInteger direction) {
        weakSelf.imageView.image = image;
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf presentViewController:zCamera animated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
