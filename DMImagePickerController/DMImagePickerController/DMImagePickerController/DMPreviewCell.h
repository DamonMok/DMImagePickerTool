//
//  DMPreviewCell.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/20.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"
#import <PhotosUI/PhotosUI.h>

@class DMPhotoPreviewView;
@class DMVideoPreviewView;
@class DMLivePhotoPreviewView;

typedef void(^singleTap)();

@interface DMPreviewCell : UICollectionViewCell

@property (nonatomic, strong)DMPhotoPreviewView *photoPreviewView;

@property (nonatomic, strong)DMVideoPreviewView *videoPreviewView;

@property (nonatomic, strong)DMLivePhotoPreviewView *livePhotoPreviewView;

@property (nonatomic, copy)singleTap singleTap;

- (void)resume;

- (void)pause;

- (void)resetZoomScale;

@end

//image Cell
@interface DMImagePreviewCell : DMPreviewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@end

//gif Cell
@interface DMGifPreviewCell : DMPreviewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@end

//video Cell
@interface DMVideoPreviewCell : DMPreviewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@end

//LivePhoto Cell
@interface DMLivePhotoPreviewCell : DMPreviewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@end



@interface DMPreviewView : UIView

@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, strong)UIImageView *imageView;//image/gif

@property (nonatomic, strong)PHLivePhotoView *livePhotoView;//livePhoto

@property (nonatomic, copy)singleTap singleTap;

@property (nonatomic, assign)BOOL requestSuccess;

- (void)resume;

- (void)pause;


//获取图片数据
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel;

//获取Gif数据
- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel;

//获取视频数据
- (void)fetchVideoDataWithAssetModel:(DMAssetModel *)assetModel;

//获取LivePhoto数据
- (void)fetchLivePhotoWithAssetModel:(DMAssetModel *)assetModel;

/**单击预览View*/
- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap;

@end

//image/gif/livePhoto
@interface DMPhotoPreviewView : DMPreviewView

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

- (void)resetSubViewsWithAsset:(PHAsset *)asset;

@end

//video
@interface DMVideoPreviewView : DMPreviewView

- (void)replay;

- (void)clearPlayerLayer;

@end





