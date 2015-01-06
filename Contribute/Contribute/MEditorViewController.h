//
//  MEditorViewController.h
//  TestAV
//
//  Created by admin on 13-7-15.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BaseViewController.h"
#import "MEditorView.h"
#import "MEditorConfig.h"

@class MEditorViewController;

@protocol MEditorDelegate <NSObject>

- (void)editorViewControllerWithDone:(MEditorViewController *)viewController;
- (void)editorViewControllerWithCancel:(MEditorViewController *)viewController;

@end

@interface MEditorViewController : UIViewController  <MEditorCellDelegate>
{
//    id <MEditorDelegate>    _delegate;
    NSMutableArray          *_arrList;
    NSString                *_leftBarString;
    MEditorView             *_editorView;
}
@property(nonatomic, assign) id <MEditorDelegate>   delegate;
@property(nonatomic, retain) NSMutableArray         *arrList;
@property(nonatomic, retain) NSString               *leftBarString;
@property(nonatomic, retain) MEditorView             *editorView;

@end
