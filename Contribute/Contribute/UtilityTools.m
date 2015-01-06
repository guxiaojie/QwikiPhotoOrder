//
//  UtilityTools.m
//  Ku6DuanKu
//
//  Created by WangDw on 13-7-23.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "UtilityTools.h"
//#import "UIImage+Resize.h"
#import <UIKit/UIKit.h>

@implementation UtilityTools



+ (UIImage*)imageThumbnail:(UIImage*)image outPutSize:(CGSize)outPutSize
{
    UIGraphicsBeginImageContext(outPutSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, outPutSize.height);
    float scale = MAX(outPutSize.width/image.size.width, outPutSize.height/image.size.height);
    CGContextScaleCTM(context, scale, -scale);
    
    float x = 0, y = 0;
    x = (image.size.width - outPutSize.width/scale)*0.5;
    y = (image.size.height - outPutSize.height/scale)*0.5;
    CGRect frame = CGRectMake(-x, -y, image.size.width, image.size.height);
    CGContextDrawImage(context, frame, image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}


@end
