//
//  DMPreviewCell1.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/20.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@class DMImageGifPreviewView;

typedef void(^singleTap)();

@interface DMPreviewCell1 : UICollectionViewCell

@property (nonatomic, strong)DMImageGifPreviewView *imageGifPreviewView;

@property (nonatomic, copy)singleTap singleTap;

- (void)resume;

- (void)pause;

@end

//imageCell
@interface DMImagePreviewCell : DMPreviewCell1

@property (nonatomic, strong)DMAssetModel *assetModel;

@end

//gifCell
@interface DMGifPreviewCell : DMPreviewCell1

@property (nonatomic, strong)DMAssetModel *assetModel;

@end



@interface DMPreviewView : UIView

@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, copy)singleTap singleTap;

- (void)resume;

- (void)pause;


//获取图片数据
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel;

//获取Gif数据
- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel;

/**单击预览View*/
- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap;

@end

@interface DMImageGifPreviewView : DMPreviewView

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@end


