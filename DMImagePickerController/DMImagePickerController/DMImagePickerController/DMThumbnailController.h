//
//  DMThumbnailController.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"
#import "DMPhotoManager.h"
#import "DMDefine.h"

@interface DMThumbnailController : UIViewController

/**相册模型*/
@property (nonatomic, strong)DMAlbumModel *albumModel;

/**是否从点击相册列表进来*/
@property (nonatomic, assign)BOOL isFromTapAlbum;

@end
