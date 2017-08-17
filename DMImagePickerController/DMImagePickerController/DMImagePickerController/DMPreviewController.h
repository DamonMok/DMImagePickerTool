//
//  DMPreviewController.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@interface DMPreviewController : UIViewController

@property (nonatomic, strong)NSArray *arrAssetModel;

@property (nonatomic, assign)NSInteger selectedIndex;

@property (nonatomic, copy)void (^goBcakHandle)();

@end
