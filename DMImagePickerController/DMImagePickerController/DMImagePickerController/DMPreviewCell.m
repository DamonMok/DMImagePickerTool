//
//  DMPreviewCell.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/20.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPreviewCell.h"
#import "DMPhotoManager.h"
#import "DMDefine.h"
#import "UIView+layout.h"
#import "DMProgressView.h"

#pragma mark - DMPreviewCell
@implementation DMPreviewCell
//lazy load
- (DMPhotoPreviewView *)photoPreviewView {
    
    if (!_photoPreviewView) {
        _photoPreviewView = [[DMPhotoPreviewView alloc] initWithFrame:self.bounds];
        
        __weak typeof(self) weakself = self;
        _photoPreviewView.singleTap = ^{
            
            if (weakself.singleTap) {
                weakself.singleTap();
            }
        };
        [self.contentView addSubview:_photoPreviewView];
    }
    
    return _photoPreviewView;
}

- (DMVideoPreviewView *)videoPreviewView {

    if (!_videoPreviewView) {
        _videoPreviewView = [[DMVideoPreviewView alloc] initWithFrame:self.bounds];
        
        __weak typeof(self) weakself = self;
        _videoPreviewView.singleTap = ^{
            
            if (weakself.singleTap) {
                weakself.singleTap();
            }
        };
        [self.contentView addSubview:_videoPreviewView];
    }
    
    return _videoPreviewView;
}

- (void)resume {
}

- (void)pause {
}

- (void)resetZoomScale {

    self.photoPreviewView.scrollView.zoomScale = 1.0;
}

@end

#pragma mark - DMImagePreviewCell
@implementation DMImagePreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    if (assetModel.type == DMAssetModelTypeImage) {
        
        self.photoPreviewView.assetModel = assetModel;
        [self.photoPreviewView fetchImageWithAssetModel:assetModel];
    }
}

@end

#pragma mark - DMGifPreviewCell
@implementation DMGifPreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    if (assetModel.type == DMAssetModelTypeGif) {
        
        self.photoPreviewView.assetModel = assetModel;
        [self.photoPreviewView fetchGifWithAssetModel:assetModel];
        
    }
}

- (void)resume {
    
    [self.photoPreviewView resume];
}

- (void)pause {

    [self.photoPreviewView pause];
}

@end

#pragma mark - DMVideoPreviewCell
@implementation DMVideoPreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;

    if (assetModel.type == DMAssetModelTypeVideo) {

        self.videoPreviewView.assetModel = assetModel;
        [self.videoPreviewView fetchVideoPosterImageWithAssetModel:assetModel];
//        [self.videoPreviewView replay];
        [self.videoPreviewView clearPlayerLayer];
    }
}

- (void)pause {

    [self.videoPreviewView pause];
}

@end

#pragma mark - DMLivePhotoPreviewCell
@implementation DMLivePhotoPreviewCell

- (void)setAssetModel:(DMAssetModel *)assetModel {

    _assetModel = assetModel;
    
    if (assetModel.type == DMAssetModelTypeLivePhoto) {
        
        self.photoPreviewView.assetModel = assetModel;
        [self.photoPreviewView fetchLivePhotoWithAssetModel:assetModel];
    }
}

- (void)resume {
    
    [self.photoPreviewView resume];
}

- (void)pause {
    
    [self.photoPreviewView pause];
}

@end

#pragma mark - DMPreviewView
@implementation DMPreviewView

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView {
    
    if (!_livePhotoView) {
        
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.frame = self.bounds;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.backgroundColor = [UIColor blackColor];
        [self addSubview:_livePhotoView];
    }
    
    return _livePhotoView;
}

#pragma mark - 子类重写
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)fetchVideoPosterImageWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)fetchVideoDataWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)fetchLivePhotoWithAssetModel:(DMAssetModel *)assetModel {
}

- (void)singleTapPreviewView:(UITapGestureRecognizer *)tap {
}

- (void)resume {
}

- (void)pause {
}

@end

#pragma mark - DMPhotoPreviewView
@interface DMPhotoPreviewView ()<UIScrollViewDelegate>

@end

@implementation DMPhotoPreviewView

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
        [self.containerView addSubview:self.livePhotoView];
    }
    
    return self;
}

#pragma mark 获取图片
- (void)fetchImageWithAssetModel:(DMAssetModel *)assetModel {

    self.livePhotoView.hidden = YES;
    self.imageView.hidden = NO;
    
    CGFloat targetWidth = MIN(assetModel.asset.pixelWidth, KScreen_Width);
    
    DMProgressView *progressView = [DMProgressView showAddedTo:self];
    [[DMPhotoManager shareManager] requestImageForAsset:assetModel.asset targetSize:CGSizeMake(targetWidth, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.imageView.image = image;
        [self resetSubViewsWithAsset:assetModel.asset];
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        //iCloud
        if (!error) {
            
            progressView.progress = progress;
            
            if (progress >= 1) {
                
                [progressView hide];
            }
        }
    }];
}

#pragma mark 获取Gif
- (void)fetchGifWithAssetModel:(DMAssetModel *)assetModel {

    self.livePhotoView.hidden = YES;
    self.imageView.hidden = NO;
    
    [[DMPhotoManager shareManager] requestGifImageForAsset:assetModel.asset complete:^(UIImage *image, NSDictionary *info) {
        
        self.imageView.image = image;
        [self resetSubViewsWithAsset:assetModel.asset];
    }];
}

#pragma mark 获取LivePhoto
- (void)fetchLivePhotoWithAssetModel:(DMAssetModel *)assetModel {
    
    self.imageView.hidden = YES;
    self.livePhotoView.hidden = NO;
    
    DMProgressView *progressView = [DMProgressView showAddedTo:self];
    [[DMPhotoManager shareManager] requestLivePhotoForAsset:assetModel.asset targetSize:self.bounds.size complete:^(PHLivePhoto *livePhoto, NSDictionary *info) {
        
        self.livePhotoView.livePhoto = livePhoto;
        [self resetSubViewsWithAsset:assetModel.asset];
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        //iCloud
        if (!error) {
            
            progressView.progress = progress;
            
            if (progress >= 1) {
                
                [progressView hide];
            }
        }
    }];
}

//子控件frame
- (void)resetSubViewsWithAsset:(PHAsset *)asset {
    
    CGFloat width = MIN(KScreen_Width, asset.pixelWidth);
    
    CGFloat scale = (CGFloat)asset.pixelHeight/asset.pixelWidth;
    
    CGFloat height = width * scale;
    
    self.containerView.frame = CGRectMake((KScreen_Width-width)/2, 0, width, height);
    
    if (height<KScreen_Height) {
        
        self.containerView.center = CGPointMake(KScreen_Width/2, KScreen_Height/2);
    }
    
    self.imageView.frame = self.containerView.bounds;
    self.livePhotoView.frame = self.containerView.bounds;
    self.scrollView.contentSize = CGSizeMake(width, MAX(KScreen_Height, height));
    
}

#pragma mark 单双击
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

#pragma mark - scrollView代理
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

#pragma mark - scrollView代理
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

#pragma mark - Gif播放/暂停方法
//暂停Gif/LivePhoto
- (void)pause {
    
    if (self.assetModel.type == DMAssetModelTypeGif) {
        
        [self pauseLayer:self.imageView.layer];
        
    } else if (self.assetModel.type == DMAssetModelTypeLivePhoto) {
    
        [self.livePhotoView stopPlayback];
    }
}

//播放Gif/LivePhoto
- (void)resume {
    
    if (self.assetModel.type == DMAssetModelTypeGif) {
        
        [self resumeLayer:self.imageView.layer];
        
    } else if (self.assetModel.type == DMAssetModelTypeLivePhoto) {
        
//        [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }
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


#pragma mark - DMVideoPreviewView
@interface DMVideoPreviewView ()

@property (nonatomic, strong)UIButton *btnPlay;

@property (nonatomic, strong)AVPlayer *player;

@property (nonatomic, strong)AVPlayerLayer *playerLayer;

@property (nonatomic, strong)AVPlayerItem *playerItem;

@end

@implementation DMVideoPreviewView
//lazy load
- (UIButton *)btnPlay {
    
    if (!_btnPlay) {
        _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"Fav_List_Video_Play"] forState:UIControlStateNormal];
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"Fav_List_Video_Play_HL"] forState:UIControlStateHighlighted];
        [_btnPlay addTarget:self action:@selector(playStatusDidChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnPlay];
    }
    
    return _btnPlay;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playStatusDidChange)];
        [self addGestureRecognizer:tap];
        
    }
    
    return self;
}

#pragma mark 获取视频封面
- (void)fetchVideoPosterImageWithAssetModel:(DMAssetModel *)assetModel {
    
    CGSize posterSize = self.bounds.size;
    
    [[DMPhotoManager shareManager] requestImageForAsset:assetModel.asset targetSize:posterSize complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.imageView.image = image;
        [self resetSubViews];
        self.imageView.hidden = NO;
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
        NSLog(@"%@", [NSThread currentThread]);
    }];
}

//frame
- (void)resetSubViews {

    self.imageView.frame = self.bounds;
    [self addSubview:self.imageView];
    
    self.btnPlay.frame = CGRectMake(0, 0, 82, 82);
    self.btnPlay.center = CGPointMake(KScreen_Width*0.5, KScreen_Height*0.5);
    [self bringSubviewToFront:self.btnPlay];
    
}

#pragma mark - 视频播放/暂停控制
#pragma mark 点击屏幕
- (void)playStatusDidChange {
    
    if (!self.playerLayer) {
        
        [[DMPhotoManager shareManager] requestVideoDataForAsset:self.assetModel.asset complete:^(AVPlayerItem *playerItem, NSDictionary *info) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.playerItem = playerItem;
                
                self.player = [AVPlayer playerWithPlayerItem:playerItem];
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                
                //加载完成的监听
                [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
                //播放结束的监听
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                //播放期间切换到后台导致暂停的监听
                [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
                
                [self.layer addSublayer:self.playerLayer];//播放结束通知
                self.playerLayer.frame = self.bounds;
                [self resetPlayerStatus];
                
            });
            
            
        }];
        
    } else {
    
        [self resetPlayerStatus];
    }
}

#pragma mark 播放/暂停之间的切换
- (void)resetPlayerStatus {

    CMTime currentTime = self.player.currentItem.currentTime;
    CMTime durationTime = self.player.currentItem.duration;
    
    if (self.player.rate == 0) {
        //播放
        if (currentTime.value == durationTime.value) {
            
            [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        
        [self.player play];
        self.btnPlay.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"willPlay" object:nil];
        
    } else {
        //暂停
        [self.player pause];
        self.btnPlay.hidden = NO;
        [self bringSubviewToFront:self.btnPlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"willPause" object:nil];
    }
}

#pragma mark 播放完毕
- (void)didPlayFinish {

    self.btnPlay.hidden = NO;
    [self bringSubviewToFront:self.btnPlay];
    [self.playerItem seekToTime:kCMTimeZero];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didPlayToEndTime" object:nil];
}

//暂停
- (void)pause {

    [self.player pause];
    self.btnPlay.hidden = NO;
    [self bringSubviewToFront:self.btnPlay];
    
}

//归零
- (void)replay {

    [self.playerItem seekToTime:kCMTimeZero];
}

- (void)clearPlayerLayer {
    
    self.playerLayer = nil;
    self.playerItem = nil;
    self.imageView.hidden = YES;
}

#pragma mark 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            self.btnPlay.hidden = YES;
        }
        
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
        
    } else if ([keyPath isEqualToString:@"rate"]) {
    
        AVPlayer *player = (AVPlayer *)object;
        
        if (player.rate == 0) {
            
            self.btnPlay.hidden = NO;
            [self bringSubviewToFront:self.btnPlay];
        }
    }
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.player removeObserver:self forKeyPath:@"rate" context:nil];
    
}

@end


