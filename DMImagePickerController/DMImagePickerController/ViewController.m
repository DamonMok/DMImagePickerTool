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
#import "YYFPSLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(openImagePickerVC) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"打开相册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:btn];

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];
    
    //FPS监测
    YYFPSLabel *labFPS = [[YYFPSLabel alloc] initWithFrame:CGRectMake(80, 2, 50, 30)];
    [labFPS sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:labFPS];
}

- (void)openImagePickerVC {
    
    DMImagePickerController *imagePickerVC = [[DMImagePickerController alloc] initWithMaxImagesCount:9];
    
   [imagePickerVC setDidFinishPickImageWithHandle:^(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos){
       
       for (UIImage *image in images) {
           
           NSLog(@"%f-%f", image.size.width, image.size.height);
       }
   }];
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

@end
