//
//  MEditorCell.h
//  TestAV
//
//  Created by admin on 13-7-16.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MEditorTileView.h"
#import "MEditorConfig.h"

@class MEditorCell;

@protocol MEditorCellDelegate <NSObject>

@optional
- (void)editorCell:(MEditorCell *)cell selectedAsset:(ALAsset *)asset;
- (int)editorCellGetAllCount:(MEditorCell *)cell;
- (void)editorCell:(MEditorCell *)cell didRemoveItem:(int)index;
- (BOOL)editorCell:(MEditorCell *)cell textFieldShouldBeginEditing:(UITextField *)textField;
- (void)editorCell:(MEditorCell *)cell textFieldShouldReturn:(UITextField *)textField;
- (void)editorCell:(MEditorCell *)cell textFieldEditingChanged:(UITextField *)textField;

@end

@interface MEditorCell : UITableViewCell <UITextFieldDelegate>
{
    UITextField         *_field;
    NSMutableArray      *_arrMoment;
    NSMutableArray      *_arrSubtitle;
    NSMutableArray      *_arrMomentView;
//    id <MEditorCellDelegate> _delegate;

    NSTimer*            _editHoldTimer;
    MEditorTileView*    _dragButton;
    int                 _dragPositionOrigin;
    BOOL                _editing;
    UITouch*            _dragTouch;
    NSInteger           _positionOrigin;
    CGPoint             _dragOrigin;
    CGPoint             _touchOrigin;
    
    int                 _row;
    MEditorTileView     *_addButton;
    UIImage             *_lastAddImage;
    
    MEditorCell         *_intoCell;
    UIEvent             *_fromEvent;
    
    CGSize              _tableViewContentSize;
//    NSMutableArray      *arrButton;
}
@property(nonatomic, retain) UITextField            *field;
@property(nonatomic, retain) NSMutableArray         *arrMoment;
@property(nonatomic, retain) NSMutableArray         *arrSubtitle;
@property(nonatomic, assign) id <MEditorCellDelegate> delegate;
@property(nonatomic, assign) int row;
//@property(nonatomic, retain) MEditorTileView     *_addButton;
@property(nonatomic, assign) CGSize                 tableViewContentSize;
//@property(nonatomic, retain) NSMutableArray      *arrButton;

- (void)addTextField;
- (id)initWithStyle2:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)insertDragButton:(MEditorTileView *)button withEvent:(UIEvent*)event;
- (void)updateTextFieldPosition:(int)count;
- (void)reloadData;

@end
