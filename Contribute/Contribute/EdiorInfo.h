//
//  EdiorInfo.h
//  Ku6DuanKu
//
//  Created by admin on 13-9-10.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EdiorInfo : NSObject
{
    NSString    *subtitle;
    UIImage     *image;
    BOOL        isClose;
    UIImage     *imageThumbnail;
}
@property(nonatomic, retain) NSString   *subtitle;
@property(nonatomic, retain) UIImage    *image;
@property(nonatomic, assign) BOOL       isClose;
@property(nonatomic, retain) UIImage     *imageThumbnail;

@end
