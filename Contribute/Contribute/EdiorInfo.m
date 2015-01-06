//
//  EdiorInfo.m
//  Ku6DuanKu
//
//  Created by admin on 13-9-10.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//

#import "EdiorInfo.h"

@implementation EdiorInfo
@synthesize subtitle;
@synthesize image;
@synthesize isClose;
@synthesize imageThumbnail;

- (id)init
{
    self = [super init];
    if (self) {
        isClose = NO;
    }
    return self;
}

- (void)dealloc
{
    [subtitle release];
    [image release];
    [imageThumbnail release];
    [super dealloc];
}

@end
