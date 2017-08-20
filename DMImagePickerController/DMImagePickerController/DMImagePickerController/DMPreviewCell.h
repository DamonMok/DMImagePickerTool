//
//  DMPreviewCell.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/20.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@class DMImageGifPreviewView;
@class DMVideoPreviewView;

typedef void(^singleTap)();

@interface DMPreviewCell : UICollectionViewCell

@property (nonatomic, strong)DMImageGifPreviewView *imageGifPreviewView;

@property (nonatomic, strong)DMVideoPreviewView *videoPreviewView;

@property (nonatomic, copy)singleTap singleTap;

- (void)resume;

- (void)pause;

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

//获取视频封面
- (void)fetchVideoPosterWithAssetModel:(DMAssetModel *)assetModel;

//后去视频数据
- (void)fetchVideoDataWithAssetModel:(DMAssetModel *)assetModel;

/**单击预览View*/
- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap;

@end

@interface DMImageGifPreviewView : DMPreviewView

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@end

@interface DMVideoPreviewView : DMPreviewView

- (void)replay;

@end


