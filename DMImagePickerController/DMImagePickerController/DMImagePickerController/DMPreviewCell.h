//
//  DMPreviewCell.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/19.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@class DMImagePreviewView;
@class DMVideoPreviewView;

typedef void(^singleTap)();

@interface DMPreviewCell : UICollectionViewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, strong)DMImagePreviewView *imagePreviewView;

@property (nonatomic, strong)DMVideoPreviewView *videoPreviewView;

@property (nonatomic, copy)singleTap singleTap;

- (void)resume;

- (void)pause;

@end

//********** 图片预览View **********
@interface DMImagePreviewView : UIView

@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)UITapGestureRecognizer *single;

@property (nonatomic, copy)singleTap singleTap;

/**获取图片asset*/
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel;

/**单击预览View*/
- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap;

- (void)resume;

- (void)pause;

@end


@interface DMVideoPreviewView : UIView

@property (nonatomic, strong)DMAssetModel *assetModel;

/**获取视频asset*/
- (void)fetchVideoWithAssetModel:(DMAssetModel *)assetModel;

@end



