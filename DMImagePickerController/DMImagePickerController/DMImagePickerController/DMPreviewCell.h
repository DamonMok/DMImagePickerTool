//
//  DMPreviewCell.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

typedef void(^singleTap)();

@class DMPreviewView;
@class DMImagePreviewView;

@interface DMPreviewCell : UICollectionViewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, strong)DMPreviewView *previewView;

@property (nonatomic, copy)singleTap singleTap;

@end


//********** 预览View **********
@interface DMPreviewView : UIView

@property (nonatomic, strong)DMAssetModel *assetModel;

/**图片预览View*/
@property (nonatomic, strong)DMImagePreviewView *imagePreviewView;

@property (nonatomic, copy)singleTap singleTap;

@end


//********** 图片预览View **********
@interface DMImagePreviewView : UIView

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)UITapGestureRecognizer *single;

@property (nonatomic, copy)singleTap singleTap;


/**获取图片asset*/
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel;

/**单击预览View*/
- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap;

@end
