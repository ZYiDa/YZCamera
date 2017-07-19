//
//  ZCameraController.h
//  自定义相机测试
//
//  Created by YYKit on 2017/7/13.
//  Copyright © 2017年 kzkj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^GetThePhotoImage)(UIImage *image,NSInteger direction);
@interface ZCameraController : UIViewController
@property (nonatomic,copy) GetThePhotoImage takePhotoImage;
- (void)selectedToGetThePhotoImageWithBlock:(GetThePhotoImage)takePhotoImage;

@property (nonatomic,copy) NSString *titleString;
@property (nonatomic,strong) UIImage *previewImage;
@end
