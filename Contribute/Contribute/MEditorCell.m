//
//  MEditorCell.m
//  TestAV
//
//  Created by admin on 13-7-16.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import "MEditorCell.h"
#import <QuartzCore/QuartzCore.h>

//#define NC_ANIMATION_DURATION_FAST      0.2f
static const NSTimeInterval kQHEditHoldTimeInterval = 0.2;

@implementation MEditorCell
@synthesize field = _field;
@synthesize arrMoment = _arrMoment;
@synthesize arrSubtitle = _arrSubtitle;
@synthesize delegate = _delegate;
@synthesize row = _row;
@synthesize tableViewContentSize = _tableViewContentSize;

- (void)updateContentSize:(NSInteger)numberOfPages
{
}

- (void)updateTextFieldPosition:(int)count
{
    if (count > 6) {
        count = 6;
    }
    CGRect frame;
    frame.size = CGSizeMake(self.frame.size.width-MEDITOR_OFFET_X*2-33, 30);
    frame.origin.x = MEDITOR_OFFET_X+7;
    frame.origin.y = ((count-1)/3+1)*(MEDITOR_ASSET_H+MEDITOR_OFFET_Y)+12;
    _field.frame = frame;
}

- (void)layoutButtons
{
    [self layoutIfNeeded];
    
    int i = 0;
    for (MEditorTileView *tileView in _arrMomentView) {
        CGRect rect = CGRectMake(MEDITOR_OFFET_X+(i%3)*(MEDITOR_ASSET_W+MEDITOR_OFFET_X), MEDITOR_OFFET_Y+(i/3)*(MEDITOR_ASSET_H+MEDITOR_OFFET_Y), MEDITOR_ASSET_W, MEDITOR_ASSET_H);
        if (!tileView.dragging) {
            tileView.transform = CGAffineTransformIdentity;
            if (tileView == _dragButton) {
                tileView.frame = rect;
            }
            else {
                tileView.frame = rect;
            }
        }
        i++;
    }
    int count = self.arrMoment.count;
    [self updateTextFieldPosition:count];
}

- (void)releaseButtonDidStop
{
    _dragButton = nil;
}

- (int)cellIndex:(CGPoint)point
{
    NSArray *visibleCells = [(UITableView *)self.superview visibleCells];
    for (MEditorCell *cell in visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            _intoCell = cell;
            return cell.row;
        }
    }
    return NSNotFound;
}

- (void)removeObj:(MEditorTileView *)tileView
{
    [self.arrMoment removeObject:tileView.imageObj];
    [_arrMomentView removeObject:tileView];
}

- (void)checkButtonOverflow:(NSInteger)pageIndex
{
    if (pageIndex != self.row) {
        [self removeObj:_dragButton];
        [_intoCell insertDragButton:_dragButton withEvent:_fromEvent];
    }

}

- (void)updateTouch
{
    CGPoint origin = [_dragTouch locationInView:self];
//    NSLog(@"origin:%@\n",NSStringFromCGPoint(origin));
//    NSLog(@"convertPoint origin:%@\n",NSStringFromCGPoint([self convertPoint:origin toView:self.superview]));
    _dragButton.center = CGPointMake(_dragOrigin.x + (origin.x - _touchOrigin.x), _dragOrigin.y + (origin.y - _touchOrigin.y));
    float width = MEDITOR_OFFET_X+MEDITOR_ASSET_W;
    float height = MEDITOR_OFFET_Y+MEDITOR_ASSET_H;
    //int column = round(origin.x/width);
    int column = origin.x/width;
    //int row = round(origin.y/height);
    int row = origin.y/height;
//    NSLog(@"column:%f %f---%d---%d\n",(origin.x/width), (origin.y/height),column,row);
    int itemIndex = row*3+column;
    
//    NSInteger pageIndex = [self cellIndex:[self convertPoint:origin toView:self.superview]];
    
    if (itemIndex != _positionOrigin) {
        if (itemIndex > self.arrMoment.count) {
            itemIndex = self.arrMoment.count;
        }
        if (itemIndex != _positionOrigin) {
            [[_dragButton retain] autorelease];
            
            [self removeObj:_dragButton];
            
            if (itemIndex > self.arrMoment.count) {
                itemIndex = self.arrMoment.count;
            }
            
            BOOL didMove = itemIndex != _positionOrigin;

            [self.arrMoment insertObject:_dragButton.imageObj atIndex:itemIndex];
 
            [_arrMomentView insertObject:_dragButton atIndex:itemIndex];
            
            _positionOrigin = itemIndex;
            
//            [self checkButtonOverflow:pageIndex];
            if (didMove) {
                [UIView animateWithDuration:MEDITOR_ANIMATION_DURATION_FAST animations:^{
                    [self layoutButtons];
                }];
            }
        }
    }
}

- (void)startDraggingButton:(MEditorTileView*)button withEvent:(UIEvent*)event
{
    if (button) {
        button.transform = CGAffineTransformIdentity;
        [self addSubview:button];
        
        CGPoint dragPoint =  [self convertPoint:button.frame.origin toView:self];
        CGSize dragSize = button.frame.size;
        button.frame = CGRectMake(dragPoint.x, dragPoint.y, dragSize.width, dragSize.height);
        
        [button layoutIfNeeded];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:NC_ANIMATION_DURATION_FAST];
    
    if (_dragButton) {
        _dragButton.selected = NO;
        _dragButton.highlighted = NO;
        _dragButton.dragging = NO;
        _editing = NO;
        _dragButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        _dragButton.alpha = 1.0;
        [self layoutButtons];
    }
    
    if (button) {
        _dragButton = button;
        _dragButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
        _dragButton.alpha = 0.7;
        
#if TARGET_IPHONE_SIMULATOR
        _positionOrigin = [self.arrMoment indexOfObject:button.imageObj];
#else
        _positionOrigin = [self.arrMoment indexOfObject:button.imageObj];
#endif
        UITouch* touch = [[event allTouches] anyObject];
        _touchOrigin = [touch locationInView:self];
        _dragOrigin = button.center;
        _dragTouch = touch;
        
        button.dragging = YES;
        
    } else {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(releaseButtonDidStop)];
    }
    [UIView commitAnimations];
}

- (void)editHoldTimer:(NSTimer*)timer
{
    _editHoldTimer = nil;
    _editing = YES;
    
    NSMutableDictionary *dic = (NSMutableDictionary *)timer.userInfo;
    MEditorTileView* button = [dic objectForKey:@"button"];
    UIEvent* event = [dic objectForKey:@"event"];
    _fromEvent = event;
    
    button.selected = NO;
    button.highlighted = NO;
    [self startDraggingButton:button withEvent:event];
    
//    [button.superview bringSubviewToFront:button];
//    UITableView *tableView = (UITableView *)button.superview.superview;
//    [tableView bringSubviewToFront:button.superview];
//    UIView *headerView = [tableView headerViewForSection:0];
//    [tableView bringSubviewToFront:headerView];
    //[dic release];
}

- (void)deselectButton:(MEditorTileView*)button
{
    [button setSelected:NO];
}

- (void)removeAsset:(MEditorTileView *)tileView animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(editorCellGetAllCount:)]) {
        int count = [self.delegate editorCellGetAllCount:self];
        if (count == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"巧妇难为无米之炊，一张图片都不给，臣妾做不到啊！"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确  定", nil];
            [alert show];
            [alert release];
            return;
        }
    }
    [self removeObj:tileView];
    if (animated) {
        [UIView animateWithDuration:MEDITOR_ANIMATION_DURATION_FAST animations:^{
            if (self.arrMoment.count == 6) {
                _addButton.hidden = YES;
            }
            else {
                _addButton.hidden = NO;
            }
            [self layoutButtons];
            tileView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            tileView.alpha = 0;
        } completion:^(BOOL finished) {
            [tileView removeFromSuperview];
        }];
    }
    else {
        [tileView removeFromSuperview];
        if (self.arrMoment.count == 6) {
            _addButton.hidden = YES;
        }
        else {
            _addButton.hidden = NO;
        }
        [self layoutButtons];
    }
    if ([self.delegate respondsToSelector:@selector(editorCell:didRemoveItem:)]) {
        [self.delegate editorCell:self didRemoveItem:1];
    }
}

- (void)closeButtonTouchedUpInside:(UIButton*)closeButton {
    for (MEditorTileView* button in _arrMomentView) {
        if (button.closeButton == closeButton) {
            [self removeAsset:button animated:YES];
            return;
        }
    }
}

- (MEditorTileView *)addButtonWithItem:(UIImage *)image
{
    MEditorTileView *button = [[MEditorTileView alloc] initWithFrame:CGRectMake(0, 0, MEDITOR_ASSET_W, MEDITOR_ASSET_H)];
    if (image) {
        [button setImage:image];
    }
    [button addTarget:self action:@selector(buttonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(buttonTouchedDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:button];
    return button;
}

- (void)buttonTouchedUpInside:(MEditorTileView*)button
{
    if (_editing) {
        if (button == _dragButton) {
            [self startDraggingButton:nil withEvent:nil];
        }
    }
    else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
        [button setSelected:YES];
        [self performSelector:@selector(deselectButton:) withObject:button afterDelay:NC_ANIMATION_DURATION_FAST];
        if (button != _addButton) {
            return;
        }
        [_field resignFirstResponder];
        if ([self.delegate respondsToSelector:@selector(editorCell:selectedAsset:)]) {
            [self.delegate editorCell:self selectedAsset:nil];
        }
    }
}

- (void)buttonTouchedUpOutside:(MEditorTileView*)button
{
    if (_editing) {
        if (button == _dragButton) {
            [self startDraggingButton:nil withEvent:nil];
        }
        
    } else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
    }
}

- (void)buttonTouchedDown:(MEditorTileView*)button withEvent:(UIEvent*)event
{
    if (button == _addButton) {
        return;
    }
    if (_editing) {
        if (!_dragButton) {
            [self startDraggingButton:button withEvent:event];
        }
    }
    else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
        
        NSMutableDictionary *dicUserInfo=[NSMutableDictionary dictionary];
        [dicUserInfo setValue:(id)event forKey:@"event"];
        [dicUserInfo setValue:(id)button forKey:@"button"];
        
        _editHoldTimer = [NSTimer scheduledTimerWithTimeInterval:kQHEditHoldTimeInterval
                                                          target:self
                                                        selector:@selector(editHoldTimer:)
                                                        userInfo:(NSMutableDictionary *)dicUserInfo
                                                         repeats:NO];
    }

}

- (void)reloadData
{
    _field.text = @"";
    if (self.arrSubtitle && [self.arrSubtitle count] > 0) {
        _field.text = [self.arrSubtitle objectAtIndex:0];
    }
    for (UIView *view in _arrMomentView) {
        if (view == _addButton) {
            continue;
        }
        [view removeFromSuperview];
    }
    [_arrMomentView removeAllObjects];
    
    for (int i=0; i<[self.arrMoment count]; i++) {
        UIImage *imgTmp = [self.arrMoment objectAtIndex:i];
        MEditorTileView *tileView = [self addButtonWithItem:imgTmp];
        tileView.imageObj = imgTmp;
        
        [tileView addCloseButton];
        [tileView.closeButton addTarget:self action:@selector(closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];

        [_arrMomentView addObject:tileView];
        [tileView release];
    }
    [_arrMomentView addObject:_addButton];
    
    if (self.arrMoment.count == 6) {
        _addButton.hidden = YES;
    }
    else {
        _addButton.hidden = NO;
    }
    [self layoutButtons];
}

#pragma mark - init

- (void)addTextField
{
    _field = [[UITextField alloc] initWithFrame:CGRectZero];
    _field.delegate = self;
    _field.borderStyle = UITextBorderStyleRoundedRect;
    _field.clearButtonMode = UITextFieldViewModeAlways;
    _field.backgroundColor = MUICOLOR(238, 238, 238, 1);
    _field.textColor = [UIColor darkGrayColor];
    _field.font = [UIFont systemFontOfSize:16];
    _field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _field.returnKeyType = UIReturnKeyDone;
    [self addSubview:_field];
    [_field addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [_field setPlaceholder:@"添加字幕"];
}

- (id)initWithStyle2:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _arrMomentView = [[NSMutableArray array] retain];
        
        _lastAddImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"editor_add.png" ofType:nil]];
        _addButton = [self addButtonWithItem:_lastAddImage];
        
        _field = [[UITextField alloc] initWithFrame:CGRectZero];
        _field.delegate = self;
        _field.borderStyle = UITextBorderStyleRoundedRect;
        _field.clearButtonMode = UITextFieldViewModeAlways;
        _field.backgroundColor = MUICOLOR(238, 238, 238, 1);
        _field.textColor = [UIColor darkGrayColor];
        _field.font = [UIFont systemFontOfSize:16];
        _field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:_field];
        [_field addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [_field setPlaceholder:@"添加字幕"];
    }
    return self;
}

- (void)removeAllSubviews:(UIView *)aView
{
    while (aView.subviews.count) {
        UIView* child = aView.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (void)dealloc
{
    [self  removeAllSubviews:self];
    self.field = nil;
    self.arrMoment = nil;
    self.arrSubtitle = nil;
    [_arrMomentView release];
    [_editHoldTimer invalidate];
    _editHoldTimer = nil;
//    [_dragButton release];
    [_addButton release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (_dragButton) {
        for (UITouch* touch in touches) {
            if (touch == _dragTouch) {
                [self updateTouch];
                break;
            }
        }
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event
{
    if ([super respondsToSelector:@selector(touchesEnded:withEvent:)]) {
        [super touchesEnded:touches withEvent:event];
    }
}

#pragma mark - textField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    NSLog(@"scroll.frame:%@",NSStringFromCGSize(scroll.contentSize));
//    NSLog(@"cell:%@ \n ",NSStringFromCGRect(self.frame));
//    NSLog(@"offY:%f \n ",offY);
    //    float offY2 = (int)offY%(int)scroll.frame.size.height;
    if ([self.delegate respondsToSelector:@selector(editorCell: textFieldShouldBeginEditing:)]) {
        return [self.delegate editorCell:self textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (int)getTextLengh:(NSString *)strText
{
    int iLengh=0;
    for (int i=0; i<[strText length]; i++) {
        int iCha = [strText characterAtIndex:i];
        if (iCha>=0 && iCha<=127) {
            iLengh ++;
        }
        else {
            iLengh +=2;
        }
    }
    return iLengh;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length != 0) {
        return YES;//can delete
    }
    BOOL basic = YES;
    int iLengh=[self getTextLengh:textField.text];
    NSUInteger newLength = iLengh + [string length] - range.length;
    if (newLength > 28 ){
        basic = NO;
    }
    return basic;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //delegate用于add moment 后 tableViewContentSize 再次更新
    if ([self.delegate respondsToSelector:@selector(editorCell:textFieldShouldReturn:)]) {
        [self.delegate editorCell:self textFieldShouldReturn:textField];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(editorCell:textFieldEditingChanged:)]) {
        [self.delegate editorCell:self textFieldEditingChanged:textField];
    }
    if (self.arrSubtitle.count > 0) {
        [self.arrSubtitle removeObjectAtIndex:0];
    }
    [self.arrSubtitle insertObject:textField.text atIndex:0];
}

#pragma mark - different cell

- (void)insertDragButton:(MEditorTileView *)button withEvent:(UIEvent*)event
{    
    button.selected = NO;
    button.highlighted = NO;
    _dragButton = button;
    _editing = YES;
    [self startDraggingButton:button withEvent:event];
}

@end
