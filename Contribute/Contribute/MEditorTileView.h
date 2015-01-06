//
//  MEditorTileView.h
//  TestAV
//
//  Created by admin on 13-7-17.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EdiorInfo.h"

@interface MEditorTileView : UIButton//UIImageView
{
    ALAsset *_asset;
    UIImage *_imageObj;
    BOOL    _dragging;
    BOOL                editing;
    
    UIButton*           closeButton;
    EdiorInfo *item;
}
@property (nonatomic, retain) ALAsset *asset;
@property (nonatomic, retain) UIImage *imageObj;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, retain) UIButton* closeButton;
@property (nonatomic, retain) EdiorInfo *item;

- (id)initWithFrame:(CGRect)frame item:(EdiorInfo*)aItem;
- (void)addCloseButton;
- (void)removeCloseButton;
- (void)setImage:(UIImage *)image;

@end
