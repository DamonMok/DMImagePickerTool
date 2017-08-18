//
//  DMPreviewCell.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPreviewCell.h"
#import "DMPhotoManager.h"
#import "DMDefine.h"
#import "UIView+layout.h"
#import "UIImage+git.h"

@implementation DMPreviewCell

- (DMPreviewView *)previewView {
    
    if (!_previewView) {
        
        _previewView = [[DMPreviewView alloc] init];
        [self.contentView addSubview:_previewView];
    }
    
    return _previewView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
    
        [self initViewWithFrame:frame];
    }
    
    return self;
}

- (void)initViewWithFrame:(CGRect)frame {
    
    self.previewView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.previewView.backgroundColor = [UIColor blackColor];
    
    
    __weak typeof(self) weakSelf = self;
    self.previewView.singleTap = ^{
        
        if (weakSelf.singleTap) {
            weakSelf.singleTap();
        }
    };
}

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    self.previewView.assetModel = assetModel;
}

@end


@implementation DMPreviewView

- (DMImagePreviewView *)imagePreviewView {
    
    if (!_imagePreviewView) {
        
        _imagePreviewView = [[DMImagePreviewView alloc] initWithFrame:self.bounds];
        _imagePreviewView.backgroundColor = [UIColor blackColor];
        _imagePreviewView.singleTap = self.singleTap;
        
    }
    
    return _imagePreviewView;
}

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (_assetModel.type) {
        case DMAssetModelTypeImage:
            //加载图片预览View
            [self addSubview:self.imagePreviewView];
            [self.imagePreviewView fetchImageWithAssetModel:assetModel];
            break;
            
        case DMAssetModelTypeGif:
            //加载Gif预览View
            //加载图片预览View
            [self addSubview:self.imagePreviewView];
            [self.imagePreviewView fetchImageWithAssetModel:assetModel];
            break;
            
        default:
            break;
    }
}

@end


@interface DMImagePreviewView ()<UIScrollViewDelegate>

@end

@implementation DMImagePreviewView

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor blackColor];
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

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initViewWithFrame:frame];
    }
    
    return self;
}

- (void)initViewWithFrame:(CGRect)frame {
    
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

- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel {
    
    CGFloat targetWidth = MIN(assetModel.asset.pixelWidth, KScreen_Width);
    
    if (assetModel.type == DMAssetModelTypeGif) {
        //Gif
        [[DMPhotoManager shareManager] requestImageDataForAsset:assetModel.asset complete:^(NSData *imageData, NSDictionary *info) {
            
            UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
            self.imageView.image = image;
            [self resetSubViewsWithAsset:assetModel.asset];
        }];
        
    } else {
        //image
        [[DMPhotoManager shareManager] requestImageForAsset:assetModel.asset targetSize:CGSizeMake(targetWidth, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
            
            self.imageView.image = image;
            [self resetSubViewsWithAsset:assetModel.asset];
        }];
    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self pauseLayer:self.imageView.layer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [self resumeLayer:self.imageView.layer];
}

//暂停gif的方法
-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续gif的方法
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
