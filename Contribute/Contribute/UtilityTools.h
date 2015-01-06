//
//  UtilityTools.h
//  Ku6DuanKu
//
//  Created by WangDw on 13-7-23.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//

#define IS_CH_SYMBOL(chr) ((int)(chr)>127)
#import <Foundation/Foundation.h>

@interface UtilityTools : NSObject

+ (UIImage *)resizeImageForScreen:(UIImage *)image;
+ (UIImage *)resizeImageForDK:(UIImage *)image;
+ (UIImage *)resizeImageForDKPreview:(UIImage *)image;

+ (UIImage *)imageFromText:(NSString *)text;

+ (UIImage*)resizeImage:(UIImage*)image toWidth:(NSInteger)width height:(NSInteger)height;
+ (UIImage*)imageThumbnailToUpload:(UIImage*)image outPutSize:(CGSize)outPutSize;
+ (UIImage*)imageThumbnail:(UIImage*)image outPutSize:(CGSize)outPutSize;
+ (void)setAudioSessionPlayBack;
+ (void)setAudioSessionAllowMix:(UInt32)isAllow;
+ (void)setAudioSessionShoudDuck:(UInt32)shouldDuck;
+ (BOOL)stringContainsEmoji:(NSString *)string;
+ (BOOL)isAPIAvailable:(NSString*)reqSysVer;
+ (NSString*)getDate:(NSTimeInterval)time;
+ (BOOL)isPureInt:(NSString *)string;
+ (BOOL)checkCh:(NSString *)str;
+ (BOOL)stringIsValidEmail:(NSString *)checkString;
+ (int)getStringLength:(NSString *)str;
+ (UIImage *)findPerfectImage:(NSArray *)imageArr;

//+ (CALayer *)layerOfView:(UIView *)view;
//+ (UIImage *)imageWithColor: (UIColor *)color;

+ (void)uploadLog:(NSString *)state;

@end
