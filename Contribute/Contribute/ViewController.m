//
//  ViewController.m
//  Contribute
//
//  Created by guxiaojie on 1/4/15.
//  Copyright (c) 2015 ___Qihoo___. All rights reserved.
//

#import "ViewController.h"
#import "MEditorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)changeToObj:(NSMutableArray *)editorArray subtitleDic:(NSMutableDictionary **)subtitleDic
{
    NSMutableArray *objArray = [NSMutableArray array];
    
    UIImage *lastAddImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"editor_add.png" ofType:nil]];
    
    int i = 0;
    for (NSDictionary *dic in editorArray) {
        NSMutableArray *arrImgA = [NSMutableArray array];
        for (UIImage *image in [dic objectForKey:MEDITOR_IMAGE_KEY]) {
            EdiorInfo *item = [[EdiorInfo alloc] init];
            item.image = image;
            [arrImgA addObject:item];
            [item release];
        }
        
        EdiorInfo *item = [[EdiorInfo alloc] init];
        item.image = lastAddImage;
        item.isClose = YES;
        [arrImgA addObject:item];
        [item release];
        
        [objArray addObject:arrImgA];
        
        NSMutableArray *subtitleArr = [dic objectForKey:MEDITOR_SUBTITLE_KEY];
        if ([subtitleArr count] >= 1) {
            NSString *subtitle = [subtitleArr objectAtIndex:0];
            if (subtitle) {
                [(*subtitleDic) setObject:subtitle forKey:[NSNumber numberWithInt:i]];
            }
        }
        i++;
    }
    return objArray;
}

- (IBAction)test:(id)sender {
//    NSMutableArray *editorArray = [NSMutableArray array];
//    NSMutableArray *arrTemp = [NSMutableArray arrayWithObjects:@"cd01.png", @"cd02.png", nil];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:arrTemp, MEDITOR_IMAGE_KEY,[NSMutableArray array], MEDITOR_SUBTITLE_KEY, nil];
//    [editorArray addObject:dic];
//    
//    NSMutableArray *arrTemp1 = [NSMutableArray arrayWithObjects:@"cd01.png", @"cd02.png", @"cd07.png", @"cd08.png", @"cd07.png", nil];
//    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:arrTemp1, MEDITOR_IMAGE_KEY,[NSMutableArray array], MEDITOR_SUBTITLE_KEY, nil];
//    
//    NSMutableArray *arrTemp2 = [NSMutableArray arrayWithObjects:@"cd01.png", @"cd02.png", @"cd04.png", @"cd05.png", @"cd06.png", @"cd04.png", nil];
//    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:arrTemp2, MEDITOR_IMAGE_KEY,[NSMutableArray array], MEDITOR_SUBTITLE_KEY, nil];
//    [editorArray addObject:dic2];
//    [editorArray addObject:dic1];
//    
//    NSMutableDictionary *subtitleDic = [NSMutableDictionary dictionary];
//    NSMutableArray *objArray = [self changeToObj:editorArray subtitleDic:&subtitleDic];
    
    
    NSMutableArray *objArray = [NSMutableArray array];
    NSMutableArray *arrImg = [NSMutableArray arrayWithObjects: @"cd02.png", @"cd03.png", @"cd04.png", @"cd05.png",  nil];
    NSMutableArray *arrImgA = [NSMutableArray array];
    for (NSString *string in arrImg) {
        [arrImgA addObject:[UIImage imageNamed:string]];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:arrImgA, MEDITOR_IMAGE_KEY,[NSMutableArray array], MEDITOR_SUBTITLE_KEY, nil];
    [objArray addObject:dic];
    NSMutableArray *arrImg1 = [NSMutableArray arrayWithObjects: @"cd02.png", @"cd03.png", @"cd04.png", @"cd05.png", @"cd06.png", nil];
    NSMutableArray *arrImgB = [NSMutableArray array];
    for (NSString *string in arrImg1) {
        [arrImgB addObject:[UIImage imageNamed:string]];
    }
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:arrImgB, MEDITOR_IMAGE_KEY,[NSMutableArray array], MEDITOR_SUBTITLE_KEY, nil];
    [objArray addObject:dic1];
//    editorCtrl.arrList = (NSMutableArray *)arr;
    
    MEditorViewController *editorCtrl1 = [[MEditorViewController alloc] init];
    editorCtrl1.arrList = objArray;
    UINavigationController *navigation1 = [[UINavigationController alloc] initWithRootViewController:editorCtrl1];
    [self presentViewController:navigation1 animated:YES completion:^{
        
    }];
//    [self.navigationController presentModalViewController:navigation1 animated:YES];
    [navigation1 release];
    [editorCtrl1 release];
}
@end
