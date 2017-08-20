//
//  DMPreviewCell1.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/20.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPreviewCell1.h"
#import "DMPhotoManager.h"
#import "DMDefine.h"
#import "UIView+layout.h"

@implementation DMPreviewCell1

- (DMImageGifPreviewView *)imageGifPreviewView {
    
    if (!_imageGifPreviewView) {
        _imageGifPreviewView = [[DMImageGifPreviewView alloc] initWithFrame:self.bounds];
        
        __weak typeof(self) weakself = self;
        _imageGifPreviewView.singleTap = ^{
            
            if (weakself.singleTap) {
                weakself.singleTap();
            }
        };
        [self.contentView addSubview:_imageGifPreviewView];
    }
    
    return _imageGifPreviewView;
}

- (void)resume {
}

- (void)pause {
}

@end

@implementation DMImagePreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    if (assetModel.type == DMAssetModelTypeImage) {
        
        [self.imageGifPreviewView fetchImageWithAssetModel:assetModel];
    }
}

@end

@implementation DMGifPreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    if (assetModel.type == DMAssetModelTypeGif) {
        
        [self.imageGifPreviewView fetchGifWithAssetModel:assetModel];
        
    }
}

- (void)resume {
    
    [self.imageGifPreviewView resume];
}

- (void)pause {

    [self.imageGifPreviewView pause];
}

@end


@implementation DMPreviewView

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap {
}

- (void)resume {
}

- (void)pause {
}

@end


@interface DMImageGifPreviewView ()<UIScrollViewDelegate>

@end

@interface DMImageGifPreviewView ()<UIScrollViewDelegate>

@end

@implementation DMImageGifPreviewView

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.delaysContentTouches = NO;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.delaysContentTouches = NO;
    }
    
    return _scrollView;
}

- (UIView *)containerView {
    
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    
    return _containerView;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPreviewView:)];
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapPreviewView:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
        
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.containerView];
        [self.containerView addSubview:self.imageView];
    }
    
    return self;
}

- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel {

    CGFloat targetWidth = MIN(assetModel.asset.pixelWidth, KScreen_Width);
    
    [[DMPhotoManager shareManager] requestImageForAsset:assetModel.asset targetSize:CGSizeMake(targetWidth, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.imageView.image = image;
        [self resetSubViewsWithAsset:assetModel.asset];
    }];
}

- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel {

    [[DMPhotoManager shareManager] requestImageDataForAsset:assetModel.asset complete:^(UIImage *image, NSDictionary *info) {
        
        self.imageView.image = image;
        [self resetSubViewsWithAsset:assetModel.asset];
    }];
}

- (void)resetSubViewsWithAsset:(PHAsset *)asset {
    
    UIImage *image = self.imageView.image;
    
    CGFloat width = MIN(KScreen_Width, asset.pixelWidth);
    
    CGFloat scale = image.size.height/image.size.width;
    
    CGFloat height = width * scale;
    
    self.containerView.frame = CGRectMake((KScreen_Width-width)/2, 0, width, height);
    
    if (height<KScreen_Height) {
        
        self.containerView.center = CGPointMake(KScreen_Width/2, KScreen_Height/2);
    }
    
    self.imageView.frame = self.containerView.bounds;
    self.scrollView.contentSize = CGSizeMake(width, MAX(KScreen_Height, height));
    
}

- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap {

    if (self.singleTap) {
        self.singleTap();
    }
}

- (void)doubleTapPreviewView:(UITapGestureRecognizer *)tap {
    
    CGFloat zoomScale = self.scrollView.zoomScale == 1.0 ? 3.0: 1.0;
    
    CGPoint tapPoint = [tap locationInView:tap.view];
    
    CGRect zoomRect;//要放大的区域
    
    CGFloat zoomHeight = self.scrollView.dm_height/zoomScale;
    CGFloat zoomWidth = self.scrollView.dm_width/zoomScale;
    CGFloat zoomX = tapPoint.x - (zoomWidth*0.5);
    CGFloat zoomY = tapPoint.y - (zoomHeight*0.5);
    zoomRect = CGRectMake(zoomX, zoomY, zoomWidth, zoomHeight);
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

//指定放大的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

//缩放会调用此方法调整位置
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.dm_width > scrollView.contentSize.width) ? (scrollView.dm_width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.dm_height > scrollView.contentSize.height) ? (scrollView.dm_height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self pause];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self resume];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
    [self pause];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    [self resume];
}

//暂停gif
- (void)pause {
    
    [self pauseLayer:self.imageView.layer];
}

//播放gif
- (void)resume {
    
    [self resumeLayer:self.imageView.layer];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] -    pausedTime;
    layer.beginTime = timeSincePause;
}

@end



