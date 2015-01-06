//
//  MEditorView.h
//  Ku6DuanKu
//
//  Created by admin on 13-9-5.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MEditorTileView.h"
#import "MEditorView.h"
#import "MTableView.h"
#import "MEditorCell.h"
#import "MEditorConfig.h"
//#import "KGroupViewController.h"

@class MEditorViewController;
@class MEditorView;

@interface MEditorView : UIView <UITableViewDataSource, UITableViewDelegate, MEditorCellDelegate>//, MAssetExplorerDelegate>
{
    NSMutableArray*     _pages;
    NSMutableArray*     _buttons;
    NSMutableArray*     _subtitlePages;

    MTableView          *tableList;

//    NSMutableArray      *_arrList;

    NSTimer*            _editHoldTimer;
    NSTimer*            _springLoadTimer;

    MEditorTileView*    _dragButton;
    UITouch*            _dragTouch;

    CGPoint             _dragOrigin;
    CGPoint             _touchOrigin;
    NSInteger           _positionOrigin;
    NSInteger           rowCount;
    NSInteger           columnCount;
//    CGFloat             buttonWidth;
    NSInteger                 currentPageIndex;
    
    NSInteger                 _dragButtonCellIndex;
    NSInteger                 _dragButtonCellIndexOrigin;//原始cell
    NSInteger                 _dragButtonCellIndexLast;//最后一次进入的cell
    
    BOOL                _editing;
    BOOL                _springing;
    BOOL                _editable;
    BOOL                _moving;

    float               dragOffset;
    
    BOOL                dragBtnMoveTo7;
    BOOL                dragBtnMoveTo6;
    
    MEditorCell             *responderCell;
    CGSize                  _tableViewContentSize;
    NSInteger                     addToCellRow;
    MEditorViewController   *editorViewController;
    BOOL                    showKeyboard;

    BOOL                    _addMonemt;
    NSTimer                 *_addMonemtTimer;
}
@property(nonatomic, assign) CGSize tableViewContentSize;
@property(nonatomic, assign) MEditorViewController *editorViewController;
@property(nonatomic, assign) BOOL moving;
@property(nonatomic, retain) NSMutableArray*     pages;
@property(nonatomic, retain) NSMutableArray*     subtitlePages;

- (id)initWithFrame:(CGRect)frame withData:(NSMutableArray *)array withSubtitle:(NSMutableArray *)subtitle;

@end
