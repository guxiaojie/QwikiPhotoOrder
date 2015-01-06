//
//  MEditorTileView.m
//  TestAV
//
//  Created by admin on 13-7-17.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import "MEditorTileView.h"
#import "UtilityTools.h"
#import <QuartzCore/QuartzCore.h>

@implementation MEditorTileView
@synthesize asset = _asset;
@synthesize imageObj = _imageObj;
@synthesize dragging = _dragging;
@synthesize editing;
@synthesize closeButton;
@synthesize item;

- (void)dealloc
{
    [_asset release];
    [_imageObj release];
    [self removeCloseButton];
    [item release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame item:(EdiorInfo*)aItem
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.item = aItem;
        self.backgroundColor = [UIColor clearColor];
        [self setImage:item.imageThumbnail];
        if (!aItem.isClose) {
            [self addCloseButton];
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    float width = 75, height = 75;
//    image = [UtilityTools imageThumbnail:image outPutSize:CGSizeMake(width*2, height*2)];
    CGRect frame = CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-height)/2, width, height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = image;
    [self addSubview:imageView];
    imageView.layer.cornerRadius = 2.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 2;
    [imageView release];
}

- (void)removeCloseButton
{
    if (closeButton) {
        [closeButton removeFromSuperview];
        [closeButton release];
        closeButton = nil;
    }
}

- (void)addCloseButton{
    if (!closeButton) {
        CGRect rect = CGRectMake(0, 0, 25, 25);
        closeButton = [[UIButton alloc] initWithFrame:rect];
        NSBundle *weeBundle = [NSBundle bundleForClass:[self class]];
        UIImage *imgBg = [UIImage imageWithContentsOfFile:[weeBundle pathForResource:@"editor_close.png" ofType:nil]];
        [closeButton setImage:imgBg forState:UIControlStateNormal];
        [self addSubview:closeButton];
    }
}

#pragma mark -  UIResponder
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

@end
