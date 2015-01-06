//
//  MEditorViewController.m
//  TestAV
//
//  Created by admin on 13-7-15.
//  Copyright (c) 2013年 ku6. All rights reserved.
//

#import "MEditorViewController.h"
//#import "MNavigationController.h"
//#import "Config.h"
#import "UtilityTools.h"

@interface MEditorViewController ()
{
    UIView *tableViewHeader;
}
@end

@implementation MEditorViewController
@synthesize delegate = _delegate;
@synthesize arrList = _arrList;
@synthesize editorView = _editorView;
@synthesize leftBarString = _leftBarString;

- (void)leftAction
{
//#warning TEST
//    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    if (_editorView.moving) {
        return;
    }
//    [Ku6Click event:@"btn_order_cancel"];
    if ([self.delegate respondsToSelector:@selector(editorViewControllerWithCancel:)]) {
        [self.delegate editorViewControllerWithCancel:self];
    }
}

- (void)rightAction
{
    if (_editorView.moving) {
        return;
    }
    
//    [Ku6Click event:@"btn_order_done"];
    
    if (_arrList) {
        [_arrList release];
        _arrList = nil;
    }
     _arrList = [[self changeToDic:self.editorView.pages subtitleArray:self.editorView.subtitlePages] retain];
    
    if ([self.delegate respondsToSelector:@selector(editorViewControllerWithDone:)]) {
        [self.delegate editorViewControllerWithDone:self];
    }
}

- (NSMutableArray *)changeToObj:(NSMutableArray *)editorArray subtitleArray:(NSMutableArray **)subtitleArray
{
    NSMutableArray *objArray = [NSMutableArray array];
    
    UIImage *lastAddImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"editor_add.png" ofType:nil]];
    
    int i = 0;
    for (NSDictionary *dic in editorArray) {
        NSMutableArray *arrImgA = [NSMutableArray array];
        for (UIImage *image in [dic objectForKey:MEDITOR_IMAGE_KEY]) {
            EdiorInfo *item = [[EdiorInfo alloc] init];
            item.image = image;
            item.imageThumbnail = [UtilityTools imageThumbnail:image outPutSize:CGSizeMake(75*2, 75*2)];
            [arrImgA addObject:item];
            [item release];
        }
        
        EdiorInfo *item = [[EdiorInfo alloc] init];
        item.image = lastAddImage;
        item.imageThumbnail = lastAddImage;
        item.isClose = YES;
        [arrImgA addObject:item];
        [item release];
        
        [objArray addObject:arrImgA];
        
        NSMutableArray *subtitleArr = [dic objectForKey:MEDITOR_SUBTITLE_KEY];
        if ([subtitleArr count] >= 1) {
            NSString *subtitle = [subtitleArr objectAtIndex:0];
            if (subtitle) {
                [(*subtitleArray) addObject:subtitle];
            }
            else {
                [(*subtitleArray) addObject:@""];
            }
        }
        else {
            [(*subtitleArray) addObject:@""];
        }
        i++;
    }
    return objArray;
}

- (NSMutableArray *)changeToDic:(NSMutableArray *)objArray subtitleArray:(NSMutableArray *)subtitleArray
{
    NSMutableArray *editorArray = [NSMutableArray array];
    int i = 0;
    for (NSArray *itemArray in objArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSMutableArray *arrImgA = [NSMutableArray array];
        for (int j=0; j<[itemArray count]-1; j++) {
            EdiorInfo *item = [itemArray objectAtIndex:j];
            [arrImgA addObject:item.image];
        }
        [dic setObject:arrImgA forKey:MEDITOR_IMAGE_KEY];
        
        if (i < subtitleArray.count) {
            NSString *subtitle = [subtitleArray objectAtIndex:i];
            if (subtitle) {
                NSMutableArray *arrImgB = [NSMutableArray arrayWithObject:subtitle];
                [dic setObject:arrImgB forKey:MEDITOR_SUBTITLE_KEY];
            }
        }
       
        [editorArray addObject:dic];
        i++;
    }
    return editorArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self setNavgationTitle:self.leftBarString];
//    [self setRightBarButtonName:@"预览"];
//    [self setLeftBarButtonName:@"取消"];
//    [self setNavigation:self.leftBarString withLeftStr:nil withRightStr:@"预览"];
    
    CGRect tableFrame = self.view.frame;
//    tableFrame.origin.y = 0;
//    if (DK_SYSTEM_VERSION_SUPPORT_7_0)
//        tableFrame.size.height -= 64;
//    else
//        tableFrame.size.height -= 44;

    UIView *bgView = [[UIView alloc] initWithFrame:tableFrame];
    [self.view addSubview:bgView];
    [bgView setBackgroundColor:MUICOLOR(233, 240, 243, 0.6)];
    [bgView release];
    
//#if TARGET_IPHONE_SIMULATOR

    NSMutableArray *subtitleArray = [NSMutableArray array];
    NSMutableArray *objArray = [self changeToObj:_arrList subtitleArray:&subtitleArray];
    _editorView = [[MEditorView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth([[UIScreen mainScreen] bounds]), self.view.frame.size.height-64) withData:objArray withSubtitle:subtitleArray];
    _editorView.editorViewController = self;
    [self.view addSubview:_editorView];
//#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_arrList release];
    self.leftBarString = nil;
    [super dealloc];
}


@end
