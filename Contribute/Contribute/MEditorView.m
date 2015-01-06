//
//  MEditorView.m
//  Ku6DuanKu
//
//  Created by admin on 13-9-5.
//  Copyright (c) 2013年 Ku6. All rights reserved.
//

#import "MEditorView.h"
//#import "MNavigationController.h"
#import "MEditorViewController.h"
#import "UtilityTools.h"

#define DEBUG_LOG
#ifdef DEBUG_LOG
#define LOG__R(frame) NSLog(@"--%s--%d--%@",__FUNCTION__, __LINE__, NSStringFromCGRect(frame))
#define LOG__O(a) NSLog(@"---%s---%d---%@",__FUNCTION__, __LINE__, a)
#define LOG__D(d) NSLog(@"---%s---%d---%d",__FUNCTION__, __LINE__, d)
#define LOG__F(d) NSLog(@"---%s---%d---%f",__FUNCTION__, __LINE__, d)
#endif

static const CGFloat kQHMargin = 5.0f;
static const CGFloat kQHMarginX = 5.0f;
//static const CGFloat kInterval = 0.0f;

static const CGFloat kQHPadding = 5.0f;
//static const CGFloat kQHWobbleRadians = 1.5f;
//static const CGFloat kQHSpringLoadFraction = 0.18f;

static const NSTimeInterval kQHEditHoldTimeInterval = 0.5;
static const NSTimeInterval kQHSpringLoadTimeInterval = 0.1;
//static const NSTimeInterval kQHWobbleTime = 0.05;


@implementation MEditorView
@synthesize tableViewContentSize = _tableViewContentSize;
@synthesize editorViewController;
@synthesize moving = _moving;
@synthesize pages = _pages;
@synthesize subtitlePages = _subtitlePages;

- (id)initWithFrame:(CGRect)frame withData:(NSMutableArray *)array withSubtitle:(NSMutableArray *)subtitle
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteUIApplicationWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
//        self.alpha = 0.7;
        self.backgroundColor = [UIColor clearColor];
        _editable = YES;
        
        UIView *tableViewHeader = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)] autorelease];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"字幕组" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"editor_add01.png"] forState:UIControlStateNormal];
        btn.backgroundColor = MUICOLOR(78, 200, 99, 1);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        btn.frame = tableViewHeader.frame;
        [tableViewHeader addSubview:btn];
        [btn addTarget:self action:@selector(addMoment) forControlEvents:UIControlEventTouchUpInside];

        tableList = [[MTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        tableList.tableHeaderView = tableViewHeader;
        tableList.dataSource = self;
        tableList.delegate = self;
        [self addSubview:tableList];
        tableList.backgroundColor = [UIColor clearColor];
        tableList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableList.separatorColor = [UIColor lightGrayColor];
        tableList.multipleTouchEnabled = NO;
        tableList.delaysContentTouches = YES;
        tableList.editing = YES;

        columnCount = 3;
        rowCount = 2;
        
        [_buttons release];
        _buttons = [[NSMutableArray alloc] init];
        
        dragOffset = 0.0f;
        _editing = NO;
        _moving = NO;
        _addMonemt = YES;
        _pages = [[NSMutableArray alloc] init];
        
        for (NSMutableArray* page in array) {
//            NSMutableArray* pageCopy = [page mutableCopy];
            [_pages addObject:page];
//            [pageCopy release];
        }
        
        _subtitlePages = [subtitle retain];

        [tableList reloadData];
        
        [self getContentSize];
    }
    return self;
}

- (void)dealloc
{
    [_pages release];
    [_buttons release];
    [_subtitlePages release];
    [tableList release];
    
    QH_INVALIDATE_TIMER(_editHoldTimer);
    QH_INVALIDATE_TIMER(_springLoadTimer);
    
    
    [super dealloc];
}

- (void)layoutButtons{
    CGFloat pageWidth = 220;
    CGFloat y = kQHMargin, minX = 0.0f, minY = 0.0f;
    int m = 0;
    for (NSMutableArray* buttonPage in _buttons) {
        int i = 0;
        CGFloat x = kQHMarginX;
        for (MEditorTileView *button in buttonPage) {
            CGRect frame = CGRectMake(x, y, MEDITOR_ASSET_W, MEDITOR_ASSET_H);
            if (!button.dragging) {
                button.transform = CGAffineTransformIdentity;
                if (button == _dragButton) {
                    NSIndexPath *path;
                    path = [NSIndexPath indexPathForRow:_dragButtonCellIndex inSection:0];
                    if ([[_pages objectAtIndex:_dragButtonCellIndex] count] == 7) {
                        path = [NSIndexPath indexPathForRow:_dragButtonCellIndexOrigin inSection:0];
                    }
                    UITableViewCell *cell = [tableList cellForRowAtIndexPath:path];
                    if (cell) {
                        button.frame = [cell convertRect:frame toView:self];
                    }
                }
                else {
                    button.frame = frame;
                }
            }
            x += MEDITOR_ASSET_W + kQHPadding;
            if (x >= minX+pageWidth) {
                y += MEDITOR_ASSET_H + kQHPadding;
                x = minX + kQHMarginX;
            }
            
            if (button.item.isClose) {
                if (buttonPage.count >= 7) {
                    button.hidden = YES;
                }
                else {
                    button.hidden = NO;
                }
                
                if (buttonPage.count == 1) {
                    [button addCloseButton];
                    [button.closeButton addTarget:self action:@selector(closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [button removeCloseButton];
                }
            }
            
            i ++;
        }
        y = minY;
        if (_dragButton) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:m inSection:0];
            NSArray *array = [tableList indexPathsForVisibleRows];
            for ( NSIndexPath* indexPathTemp in array) {
                if (m == indexPathTemp.row)
                {
                    MEditorCell *cellTmp = (MEditorCell *)[tableList cellForRowAtIndexPath:path];
                    if (cellTmp)
                    {
                        [cellTmp updateTextFieldPosition:buttonPage.count];
                    }
                }
            }

        }
        m++;
    }
}

- (MEditorTileView*)addButtonWithItem:(EdiorInfo *)item {
    MEditorTileView *button = [[MEditorTileView alloc] initWithFrame:CGRectMake(0, 0, MEDITOR_ASSET_W, MEDITOR_ASSET_H) item:item];
    [button.closeButton addTarget:self action:@selector(closeButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(buttonTouchedDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    return button;
}

- (void)removeAllSubviews:(UIView *)aView {
    while (aView.subviews.count) {
        UIView* child = aView.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (NSIndexPath*)indexPathOfItem:(EdiorInfo *)item {
    for (NSUInteger pageIndex = 0; pageIndex < _pages.count; ++pageIndex) {
        NSArray* page = [_pages objectAtIndex:pageIndex];
        NSUInteger itemIndex = [page indexOfObject:item];
        if (itemIndex != NSNotFound) {
            NSUInteger path[] = {pageIndex, itemIndex};
            return [NSIndexPath indexPathWithIndexes:path length:2];
        }
    }
    return nil;
}

- (NSMutableArray*)pageWithItem:(EdiorInfo *)item index:(int *)index{
    int i = 0;
    for (NSMutableArray* page in _pages) {
        NSUInteger itemIndex = [page indexOfObject:item];
        if (itemIndex != NSNotFound) {
            if (index) {
                (*index) = i;
            }
            return page;
        }
        i++;
    }
    return nil;
}

- (NSMutableArray*)pageWithButton:(MEditorTileView *)button {
    NSIndexPath* path = [self indexPathOfItem:button.item];
    if (path) {
        NSInteger pageIndex = [path indexAtPosition:0];
        return [_buttons objectAtIndex:pageIndex];
        
    } else {
        return nil;
    }
}

- (void)releaseButtonDidStop {
    NSIndexPath *path = [NSIndexPath indexPathForRow:_dragButtonCellIndex inSection:0];
    UITableViewCell *cell = [tableList cellForRowAtIndexPath:path];
    if (cell) {
        [cell addSubview:_dragButton];
        
        CGPoint dragPoint =  [self convertPoint:_dragButton.frame.origin toView:cell];
        CGSize dragSize = _dragButton.frame.size;
        _dragButton.frame = CGRectMake(dragPoint.x, dragPoint.y, dragSize.width, dragSize.height);
    }
    [_dragButton removeFromSuperview];
    _dragButton = nil;

    [tableList reloadData];
}

- (MEditorCell *)getCurrentCell
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:_dragButtonCellIndex inSection:0];
    MEditorCell *cell = (MEditorCell *)[tableList cellForRowAtIndexPath:path];
    return cell;
}

- (void)manageLastAddButton:(MEditorTileView *)button
{
    NSIndexPath *path = [self indexPathOfItem:button.item];
    NSInteger pageIndex = [path indexAtPosition:0];
    NSInteger itemIndex = [path indexAtPosition:1];
    NSMutableArray *currentItemPage = [_pages objectAtIndex:pageIndex];
    if (currentItemPage.count <= 7 && (itemIndex == currentItemPage.count - 1)) {
        NSMutableArray* currentButtonPage = [_buttons objectAtIndex:pageIndex];
        
        [[_dragButton retain] autorelease];
        
        [currentButtonPage removeObjectAtIndex:itemIndex];
        [currentButtonPage insertObject:_dragButton atIndex:(currentButtonPage.count-1)];
        
        [currentItemPage removeObjectAtIndex:itemIndex];
        [currentItemPage insertObject:_dragButton.item atIndex:(currentItemPage.count-1)];
    }
//    [tableList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeEmptyCell
{
    _moving = NO;
    _editing = NO;
    tableList.scrollEnabled = YES;
    BOOL removedCell = NO;
    for (int i=0; i<_pages.count; i++) {
        NSMutableArray *itemPage = [_pages objectAtIndex:i];
        if (itemPage.count == 1) {
            [_pages removeObject:itemPage];
            if (i < [_subtitlePages count]) {
                [_subtitlePages removeObjectAtIndex:i];
            }
            removedCell = YES;
            //下面的方法引起cell刷新异常，导致——buttons内容错误
//            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
//            [tableList deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
            i--;
        }
    }
    if (removedCell) {
        [tableList reloadData];
    }
}

- (void)startDraggingButton:(MEditorTileView*)button withEvent:(UIEvent*)event {
    QH_INVALIDATE_TIMER(_springLoadTimer);
        
    if (button) {
        NSIndexPath* selectedIndexPath = [self indexPathOfItem:button.item];
        _positionOrigin = [selectedIndexPath indexAtPosition:1];
        _dragButtonCellIndexLast = _positionOrigin;
        _dragButtonCellIndex = [selectedIndexPath indexAtPosition:0];
        _dragButtonCellIndexOrigin = _dragButtonCellIndex;
        
        button.transform = CGAffineTransformIdentity;
        [self addSubview:button];

        MEditorCell *cell = [self getCurrentCell];
        CGPoint dragPoint =  [cell convertPoint:button.frame.origin toView:self];
        CGSize dragSize = button.frame.size;
        
        button.frame = CGRectMake(dragPoint.x, dragPoint.y, dragSize.width, dragSize.height);
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:NC_ANIMATION_DURATION_FAST];
    
    if (_dragButton) {
        _dragButton.selected = NO;
        _dragButton.highlighted = NO;
        _dragButton.dragging = NO;

        _dragButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        _dragButton.alpha = 1.0;

        [self layoutButtons];
    }

    if (button) {
        _dragButton = button;
        _dragButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
        _dragButton.alpha = 0.7;
        
        UITouch* touch = [[event allTouches] anyObject];
        _touchOrigin = [touch locationInView:tableList];
        _dragOrigin = button.center;
        _dragTouch = touch;
        
        button.dragging = YES;
        _moving = YES;
        tableList.scrollEnabled = NO;
    }
    else {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(releaseButtonDidStop)];
        tableList.scrollEnabled = YES;
    }
    
    [UIView commitAnimations];
}

#pragma mark -

- (void)gotoScrollTimer:(NSTimer*)timer
{
    float interval = 0.5;
    if ([(NSNumber*)timer.userInfo boolValue]) {
        dragOffset -= interval;
        float y = tableList.contentOffset.y + dragOffset;
        CGPoint offset = CGPointMake(0, y);
        if (y > 1) {
            _dragOrigin.y -= dragOffset;
            [tableList setContentOffset:offset animated:NO];
        }
        else {
            dragOffset = 0.0f;
            if (_springLoadTimer) {
                QH_INVALIDATE_TIMER(_springLoadTimer);
            }
        }
    } else {
        dragOffset += interval;
        float y = tableList.contentOffset.y + dragOffset;
        CGPoint offset = CGPointMake(0, y);
        if (offset.y <= (tableList.contentSize.height-tableList.frame.size.height)) {
            _dragOrigin.y -= dragOffset;
            [tableList setContentOffset:offset animated:NO];
        }
        else {
            dragOffset = 0.0f;
            if (_springLoadTimer) {
                QH_INVALIDATE_TIMER(_springLoadTimer);
            }
        }
    }
}

- (void)editHoldTimer:(NSTimer*)timer {
    _editing = YES;

    _editHoldTimer = nil;
    
    NSMutableDictionary *dic = (NSMutableDictionary *)timer.userInfo;
    MEditorTileView* button = [dic objectForKey:@"button"];
    UIEvent* event = [dic objectForKey:@"event"];
    
    button.selected = NO;
    button.highlighted = NO;
    dragBtnMoveTo7 = NO;
    dragBtnMoveTo6 = NO;
    [self startDraggingButton:button withEvent:event];
    
    [dic release];
}

- (void)deselectButton:(MEditorTileView *)button {
    [button setSelected:NO];
}

#pragma mark - btn touche

- (void)buttonTouchedUpInside:(MEditorTileView*)button {
    if (_editing) {
        if (button == _dragButton) {
            [self manageLastAddButton:button];//move the "Add Btn" to last
            [self startDraggingButton:nil withEvent:nil];
            [self performSelector:@selector(removeEmptyCell) withObject:nil afterDelay:NC_ANIMATION_DURATION];//NC_ANIMATION_DURATION必须>NC_ANIMATION_DURATION_FAST.重置_moving状态
        }
    } else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
        [button setSelected:YES];
        [self performSelector:@selector(deselectButton:) withObject:button afterDelay:NC_ANIMATION_DURATION_FAST];
    }
    if (button.item.isClose) {
        [responderCell.field resignFirstResponder];
        NSIndexPath *path = [self indexPathOfItem:button.item];
        NSInteger pageIndex = [path indexAtPosition:0];
        [self addPhones:pageIndex];
    }
}

- (void)buttonTouchedUpOutside:(MEditorTileView*)button {
    if (_editing) {
        if (button == _dragButton) {
            [self manageLastAddButton:button];//move the "Add Btn" to last
            [self startDraggingButton:nil withEvent:nil];
            [self performSelector:@selector(removeEmptyCell) withObject:nil afterDelay:NC_ANIMATION_DURATION];//NC_ANIMATION_DURATION必须>NC_ANIMATION_DURATION_FAST.重置_moving状态
        }
        
    } else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
    }
}

- (void)buttonTouchedDown:(MEditorTileView*)button withEvent:(UIEvent*)event {
    if (!_editable)
        return;
    if (button.item.isClose)
        return;
    if (_editing) {
        if (!_dragButton) {
            [self startDraggingButton:button withEvent:event];
        }
    } else {
        QH_INVALIDATE_TIMER(_editHoldTimer);
        
        NSMutableDictionary *dicUserInfo=[[NSMutableDictionary alloc] init];
        [dicUserInfo setValue:(id)event forKey:@"event"];
        [dicUserInfo setValue:(id)button forKey:@"button"];
        
        _editHoldTimer = [NSTimer scheduledTimerWithTimeInterval:kQHEditHoldTimeInterval
                                                          target:self
                                                        selector:@selector(editHoldTimer:)
                                                        userInfo:(NSMutableDictionary *)dicUserInfo
                                                         repeats:NO];
    }
}

- (MEditorTileView *)buttonForItem:(EdiorInfo*)item {
    NSIndexPath* path = [self indexPathOfItem:item];
    if (path) {
        NSInteger pageIndex = [path indexAtPosition:0];
        NSArray* buttonPage = [_buttons objectAtIndex:pageIndex];
        
        NSInteger itemIndex = [path indexAtPosition:1];
        return [buttonPage objectAtIndex:itemIndex];
        
    } else {
        return nil;
    }
}

- (int)getImagesCount
{
    int maxCount = 0;
    for (NSMutableArray *arr in _pages) {
        int count = arr.count-1;
        maxCount += count;
    }
    return maxCount;
}

- (void)removeItem:(EdiorInfo *)item animated:(BOOL)animated {
//    [Ku6Click event:@"btn_order_delete"];
    int itemPageIndex = NSNotFound;
    NSMutableArray* itemPage = [self pageWithItem:item index:&itemPageIndex];
    if (itemPage) {
        if (([self getImagesCount] == 1) && (itemPage.count == 2)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"巧妇难为无米之炊，一张图片都不给，臣妾做不到啊！"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确  定", nil];
            [alert show];
            [alert release];
            return;
        }
        
        MEditorTileView* button = [self buttonForItem:item];
        NSMutableArray* buttonPage = [self pageWithButton:button];
        
        [itemPage removeObject:button.item];
        if (itemPage.count <= 1) {
            [_pages removeObject:itemPage];
            if (itemPageIndex < [_subtitlePages count]) {
                [_subtitlePages removeObjectAtIndex:itemPageIndex];
            }
        }
        if (buttonPage) {
            [buttonPage removeObject:button];
            if (buttonPage.count <= 1) {
                [_buttons removeObject:buttonPage];
            }
            
            if (animated) {
                [UIView beginAnimations:nil context:button];
                [UIView setAnimationDuration:NC_ANIMATION_DURATION_FAST];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(removeButtonAnimationDidStop:finished:context:)];
                
                [self layoutButtons];
                
                button.transform = CGAffineTransformMakeScale(0.01, 0.01);
                button.alpha = 0;
                [UIView commitAnimations];
                
            } else {
                [button removeFromSuperview];
                
                [self layoutButtons];
            }
        }

        [tableList reloadData];
    }
}

- (void)closeButtonTouchedUpInside:(UIButton*)closeButton {
    if (_moving) {
        return;
    }
    for (NSArray* buttonPage in _buttons) {
        for (MEditorTileView* button in buttonPage) {
            if (button.closeButton == closeButton) {
                [self removeItem:button.item animated:YES];
                return;
            }
        }
    }
}

#pragma mark - Table view data source

- (int)getCellHeight:(int)indexPathRow
{
    NSArray *arrTmp= [_pages objectAtIndex:indexPathRow];
    int count = arrTmp.count;
    if (arrTmp.count >= 6) {
        count = 6;
    }
    float height = ceil((float)count/3)*(MEDITOR_ASSET_H+MEDITOR_OFFET_Y)+MEDITOR_TEXT_H;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellHeight:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlbumCell";
    MEditorCell *cell = (MEditorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell != nil) {
        [cell release];
        cell = nil;
    }
    if (cell == nil) {
        cell = [[MEditorCell alloc] initWithStyle2:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.delegate = self;
    NSArray *arr = [_pages objectAtIndex:indexPath.row];
    NSMutableArray* buttonPage = [NSMutableArray array];
    for (EdiorInfo *info in arr) {
        MEditorTileView *button = [self addButtonWithItem:info];
        [cell addSubview:button];
        
        if (_buttons.count>=indexPath.row) {
            [buttonPage addObject:button];
        }
    }
    if (_buttons.count>=indexPath.row) {
        if (_buttons.count>indexPath.row) {
            [_buttons removeObjectAtIndex:indexPath.row];
        }
        [_buttons insertObject:buttonPage atIndex:indexPath.row];
    }
    [cell addTextField];
    NSString *text = [_subtitlePages objectAtIndex:indexPath.row];
    if (text) {
        cell.field.text = text;
    }
    [cell updateTextFieldPosition:arr.count];
    cell.row = indexPath.row;
    
    [self layoutButtons];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.row == toIndexPath.row) {
        return;
    }
//    [Ku6Click event:@"btn_order_move"];

    id arrFrom = [[_pages objectAtIndex:fromIndexPath.row] retain];
    [_pages removeObjectAtIndex:fromIndexPath.row];
    [_pages insertObject:arrFrom atIndex:toIndexPath.row];
    [arrFrom release];
    
    id arrFrom1 = [[_subtitlePages objectAtIndex:fromIndexPath.row] retain];
    [_subtitlePages removeObjectAtIndex:fromIndexPath.row];
    [_subtitlePages insertObject:arrFrom1 atIndex:toIndexPath.row];
    [arrFrom1 release];
    
    [tableView reloadData];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{    
//    UIView *tableViewHeader = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"字幕组" forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:@"editor_add01.png"] forState:UIControlStateNormal];
//    btn.backgroundColor = MUICOLOR(78, 200, 99, 1);
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
//    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//    btn.frame = tableViewHeader.frame;
//    [tableViewHeader addSubview:btn];
//    [btn addTarget:self action:@selector(addMoment) forControlEvents:UIControlEventTouchUpInside];
//    return tableViewHeader;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50;
//}

#pragma mark -  move

- (NSInteger)getPageIndexWithPostion:(CGPoint)point
{
    NSArray *arr = [tableList visibleCells];
    for (MEditorCell *cell in arr) {
        CGRect frame = cell.frame;
        frame.size.height -= MEDITOR_TEXT_H;
        frame.origin.y = cell.frame.origin.y - tableList.contentOffset.y;
        if (CGRectContainsPoint(frame, point)) {
            return [tableList indexPathForCell:cell].row;
        }
    }
    return NSNotFound;
}

- (void)updateTouch {
    CGPoint origin = [_dragTouch locationInView:tableList];
    float buttonOriginY = _dragOrigin.y + (origin.y - _touchOrigin.y);
    _dragButton.center = CGPointMake(_dragOrigin.x + (origin.x - _touchOrigin.x), buttonOriginY);
    MEditorCell *cell = [self getCurrentCell];
    CGFloat x = origin.x - cell.frame.origin.x ;
    CGFloat y = origin.y - cell.frame.origin.y;
    NSInteger column = round(x/_dragButton.frame.size.width);
    NSInteger row = round(y/_dragButton.frame.size.height);
    NSInteger itemIndex = (row * columnCount) + column;
    
    NSInteger pageIndex = [self getPageIndexWithPostion:_dragButton.center];

    if (_dragButtonCellIndex != pageIndex) {
        _dragButtonCellIndex = pageIndex;
        _positionOrigin = -1;
    }
    
    if (pageIndex == NSNotFound) {
        _dragButtonCellIndex = _dragButtonCellIndexOrigin;
        //        pageIndex = 0;
    }
    
    if (pageIndex != NSNotFound && itemIndex != _positionOrigin) {
        NSMutableArray* currentButtonPage = [_buttons objectAtIndex:pageIndex];
        if (itemIndex > currentButtonPage.count) {
            itemIndex = currentButtonPage.count;
        }

        if ((itemIndex != _positionOrigin)) {
            dragBtnMoveTo7 = (_dragButtonCellIndexOrigin != _dragButtonCellIndex) && (currentButtonPage.count == 7);
            if (!dragBtnMoveTo7) {
                [[_dragButton retain] autorelease];
                
                NSMutableArray* itemPage = [self pageWithItem:_dragButton.item index:nil];
                NSMutableArray* buttonPage = [self pageWithButton:_dragButton];
                [itemPage removeObject:_dragButton.item];
                [buttonPage removeObject:_dragButton];
                
                if (itemIndex > currentButtonPage.count) {
                    itemIndex = currentButtonPage.count;
                }
                
                BOOL didMove = itemIndex != _positionOrigin;
                
                NSMutableArray* currentItemPage = [_pages objectAtIndex:pageIndex];
                [currentItemPage insertObject:_dragButton.item atIndex:itemIndex];
                [currentButtonPage insertObject:_dragButton atIndex:itemIndex];
                _positionOrigin = itemIndex;
                
                dragBtnMoveTo6 = ((_dragButtonCellIndexOrigin != _dragButtonCellIndex) && currentButtonPage.count == 7);
                if (dragBtnMoveTo6) {
                    _dragButtonCellIndexOrigin = _dragButtonCellIndex;
                }

                if (didMove) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:NC_ANIMATION_DURATION_FAST];
                    
                    int originY = 50;
                    float height = 0;
                    for (int i=0; i<_pages.count; i++) {
                        NSIndexPath *pathTmp = [NSIndexPath indexPathForRow:i inSection:0];
                        MEditorCell *cellTmp = (MEditorCell *)[tableList cellForRowAtIndexPath:pathTmp];
                        height = [self getCellHeight:i];
                        CGRect cellFrame = cellTmp.frame;
                        cellFrame.size.height = height;
                        cellFrame.origin.y = originY;
                        cellTmp.frame = cellFrame;
                        originY += height;
                    }
                    [self layoutButtons];
                    [UIView commitAnimations];
                }
            }
        }
    }
    
    BOOL up = _dragButton.center.y < 50;
    BOOL down = (tableList.frame.size.height - _dragButton.center.y) < 50;
    if (up || down) {
        if (!_springLoadTimer) {
            _springLoadTimer = [NSTimer scheduledTimerWithTimeInterval:kQHSpringLoadTimeInterval
                                                                target:self selector:@selector(gotoScrollTimer:)
                                                              userInfo:[NSNumber numberWithBool:up]
                                                               repeats:YES];
        }

    }
    else {
        dragOffset = 0.0f;
        if (_springLoadTimer) {
            QH_INVALIDATE_TIMER(_springLoadTimer);
        }
    }
}

#pragma mark -  UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_dragButton && !_springing) {
        for (UITouch* touch in touches) {
            if (touch == _dragTouch) {
                [self updateTouch];
                break;
            }
        }
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
}

#pragma mark - delegate

- (void)getContentSize
{
    UIScrollView *scroll = (UIScrollView *)tableList;
    self.tableViewContentSize = scroll.contentSize;
}

- (void)canAddMoment
{
    _addMonemt = YES;
    QH_INVALIDATE_TIMER(_addMonemtTimer);
}

- (void)addMoment
{
    if (_moving) {
        return;
    }
    if (!_addMonemt) {
        return;
    }
    _addMonemtTimer = [NSTimer scheduledTimerWithTimeInterval:ADD_MOMENT_DURATION target:self selector:@selector(canAddMoment) userInfo:nil repeats:NO];
    _addMonemt = NO;
    
    if (_pages.count >= 20) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"不能再加了！"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确  定", nil];
        [alert show];
        [alert release];
        return;
    }
    
//    [Ku6Click event:@"btn_order_addMoment"];

    if (responderCell) {
        [responderCell.field resignFirstResponder];
    }
    NSMutableArray *arrItem = [NSMutableArray array];
    UIImage *lastAddImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"editor_add.png" ofType:nil]];
    EdiorInfo *item = [[EdiorInfo alloc] init];
    item.image = lastAddImage;
    item.imageThumbnail = lastAddImage;
    item.isClose = YES;
    [arrItem addObject:item];
    [item release];
    [_pages insertObject:arrItem atIndex:0];

    [_subtitlePages insertObject:@"" atIndex:0];

    [tableList reloadData];
    //[tableList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    UIScrollView *scroll = (UIScrollView *)tableList;
    self.tableViewContentSize = CGSizeMake(scroll.contentSize.width, scroll.contentSize.height+150);
}

- (void)custom:(int)index
{
    int maxCount = 0;
    int currentCount = 0;
    int i = 0;
    for (NSMutableArray *arr in _pages) {
        int count = arr.count-1;
        maxCount += count;
        if (i == index) {
            currentCount = count;
        }
        i ++;
    }
    if (maxCount == PHOTOMAXCOUNT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"不能再选了！"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确  定", nil];
        [alert show];
        [alert release];
        return;
    }
    int count = MIN(PHOTOMAXCOUNT-maxCount, 6-currentCount);
    if (count <= 0) {
        return;
    }
//    KGroupViewController *groupViewController = [[KGroupViewController alloc] init];
//    groupViewController.delegate = self;
//    groupViewController.maxCount = count;
//    [groupViewController setExplorerBackBlock:^(KGroupViewController *viewController){
//        [viewController dismissModalViewControllerAnimated:YES];
//    }];
//    [groupViewController setExplorerDoneBlock:^(KGroupViewController *viewController) {
//        [viewController dismissModalViewControllerAnimated:YES];
//    }];
//    MNavigationController *navigationController = [[MNavigationController alloc] initWithRootViewController:groupViewController];
//    [groupViewController release];
//    [editorViewController presentModalViewController:navigationController animated:YES];
//    [navigationController release];
}

- (void)addPhones:(int)row
{
    if (_moving) {
        return;
    }
//    [Ku6Click event:@"btn_order_add"];
    addToCellRow = row;
#if TARGET_IPHONE_SIMULATOR
    NSMutableArray *tmp = [_pages objectAtIndex:row];
    EdiorInfo *item = [[EdiorInfo alloc] init];
    item.image = [UIImage imageNamed:@"cd07.png"];
    item.imageThumbnail = [UIImage imageNamed:@"cd07.png"];
    [tmp insertObject:item atIndex:tmp.count-1];
    [item release];

    [tableList reloadData];
    
    [self getContentSize];
#else
    [self custom:row];
#endif
}
/*
#pragma mark - KGroupViewController delegate

- (void)groupViewController:(KGroupViewController *)viewController seletedAsset:(NSArray *)assets
{
    NSMutableArray *imageArr = [_pages objectAtIndex:addToCellRow];
    for (ALAsset *aAsset in assets) {
        ALAssetRepresentation *assetRepresentation = [aAsset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];
        
        EdiorInfo *item = [[EdiorInfo alloc] init];
        item.image = fullScreenImage;
        item.imageThumbnail = [UtilityTools imageThumbnail:fullScreenImage outPutSize:CGSizeMake(75*2, 75*2)];
        [imageArr insertObject:item atIndex:imageArr.count-1];
        [item release];
    }
//    NSMutableArray *tmp = [dic objectForKey:MEDITOR_IMAGE_KEY];
//    int lenght = MIN((6-tmp.count), imageArr.count);
//    if ([imageArr count] > 0) {
//        [tmp addObjectsFromArray:[imageArr subarrayWithRange:NSMakeRange(0, lenght)]];
//    }

    [tableList reloadData];
    
    [self getContentSize];
}
*/
#pragma mark - cell delegate

- (BOOL)editorCell:(MEditorCell *)cell textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_moving) {
        return NO;
    }
    responderCell = cell;
    showKeyboard = YES;

    float keyBoardHeight = 252;
    UIScrollView *scroll = (UIScrollView *)tableList;
    float offY = cell.frame.origin.y + cell.frame.size.height - (scroll.frame.size.height - keyBoardHeight);
    offY = MAX(0, offY);
    [scroll setContentSize:CGSizeMake(scroll.contentSize.width, self.tableViewContentSize.height+keyBoardHeight)];
    [scroll setContentOffset:CGPointMake(0, offY) animated:YES];
    return YES;
}

- (void)editorCell:(MEditorCell *)cell textFieldShouldReturn:(UITextField *)textField
{
    responderCell = nil;
    showKeyboard = NO;
    UIScrollView *scroll = (UIScrollView *)tableList;
    [scroll setContentSize:self.tableViewContentSize];
}

- (void)editorCell:(MEditorCell *)cell textFieldEditingChanged:(UITextField *)textField
{
    if (textField.text) {
        [_subtitlePages removeObjectAtIndex:cell.row];
        [_subtitlePages insertObject:textField.text atIndex:cell.row];
    }
}

#pragma mark - table view
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    QH_INVALIDATE_TIMER(_editHoldTimer);
}

#pragma mark - resign active

- (void)noteUIApplicationWillResignActiveNotification:(NSNotification*)note
{
    if (_dragButton) {
        [self buttonTouchedUpInside:_dragButton];
    }
}

@end
