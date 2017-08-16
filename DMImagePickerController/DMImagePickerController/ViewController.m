//
//  ViewController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "DMImagePickerController.h"
#import <Photos/Photos.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(openImagePickerVC) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"打开相册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:btn];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];
}

- (void)openImagePickerVC {
    
    DMImagePickerController *imagePickerVC = [[DMImagePickerController alloc] initWithMaxImagesCount:9];
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

@end
