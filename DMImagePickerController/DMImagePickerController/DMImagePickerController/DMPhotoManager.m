//
//  DMPhotoManager.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoManager.h"
#import "DMDefine.h"
#import "UIImage+git.h"

@interface DMPhotoManager ()
{
    CGFloat _screenScale;
}

@end

@implementation DMPhotoManager

+ (instancetype)shareManager {
    
    static DMPhotoManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[DMPhotoManager alloc] init];
        
        [manager configParameter];
        [manager configScreenScale];
        
    });
    
    return manager;
}

#pragma mark 在这里设置相关默认参数
- (void)configParameter {
    
    self.hideEmptyAlbum = NO;
    self.showHiddenAlbum = YES;
    self.sortAscendingByCreationDate = YES;
    self.maxWidth = 414;
    
    //配置音频会话，不配置播放视频将没有声音
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
}

//6plus/6splus/7plus    屏幕宽度414 -----@3x
//非上述机型    屏幕宽度<414 -----@2x
- (void)configScreenScale {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _screenScale = screenWidth > 400 ? 3:2;
}

- (void)getAllAlbumsCompletion:(void (^)(NSArray<DMAlbumModel *> *))completion {
    
    //相册<PHAssetCollect *>
    //图片<PHAsset *>
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByCreationDate]];
    
    //获取所有相册
    PHFetchResult *smartAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *albumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    NSArray *arrAlbumResult = @[smartAlbumResult, albumResult];
    
    NSMutableArray *arrAlbum = [NSMutableArray array];
    for (PHFetchResult *albumResult in arrAlbumResult) {
        
        [albumResult enumerateObjectsUsingBlock:^(PHAssetCollection  *_Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            
            if (!result.count && self.hideEmptyAlbum) return ;
            
            
            //转成DMAlbumModel对象
            DMAlbumModel *albumModel = [DMAlbumModel albumModelWithCollection:collection assetResult:result];
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                
                //Camera Roll 相册
                [arrAlbum insertObject:albumModel atIndex:0];
            } else {
                
                if (!self.showHiddenAlbum && collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) return;
                
                [arrAlbum addObject:albumModel];
            }
            
        }];
    }
    
    if (completion) completion(arrAlbum);
    
}

- (void)getCameraRollAlbumCompletion:(void (^)(DMAlbumModel *))completion {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByCreationDate]];
    
    PHFetchResult *userAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            
            DMAlbumModel *albumModel = [DMAlbumModel albumModelWithCollection:collection assetResult:result];
            
            if (completion) {
                completion(albumModel);
            }
        }
    }];
    
}

- (PHImageRequestID)requestPosterImageWithAlbumModel:(DMAlbumModel *)albumModel complete:(void (^)(UIImage *, NSDictionary *))complete
{
    
    return [self requestImageForAsset:albumModel.coverImageAsset targetSize:CGSizeMake(KAlbumViewRowHeight, KAlbumViewRowHeight) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        if (complete) {
            
            complete(image, info);
        }
        
    } progressHandler:nil];
    
}

- (PHImageRequestID)requestTargetImageForAsset:(PHAsset *)asset isOriginal:(BOOL)isOriginal complete:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))complete {

    CGFloat targetWidth = asset.pixelWidth;
    if (targetWidth>self.maxWidth && !isOriginal) {
        targetWidth = self.maxWidth;
    }
    
    return [self requestImageForAsset:asset targetSize:CGSizeMake(targetWidth, MAXFLOAT) complete:complete progressHandler:nil];
    
}

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize complete:(void (^)(UIImage *, NSDictionary *, BOOL))complete progressHandler:(void (^)(double, NSError *, BOOL *, NSDictionary *))progressHandler {

    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    
    // 不调整
    //PHImageRequestOptionsResizeModeNone = 0,
    
    // 快速调整，性能高，targetSize可能会比定义的偏大
    //PHImageRequestOptionsResizeModeFast,
    
    // 性能比上一个慢，targetSize是准确的
    //PHImageRequestOptionsResizeModeExact,
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    //异步：接收多个结果以平衡图像的质量  同步：接收一个结果
    //PHImageRequestOptionsDeliveryModeOpportunistic = 0,
    
    //无论耗时多长，只返回一个高质量的图片
    //PHImageRequestOptionsDeliveryModeHighQualityFormat = 1,
    
    //只返回一个图片，质量可能会降低
    //PHImageRequestOptionsDeliveryModeFastFormat = 2
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //iCloud
        if (progressHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
               progressHandler(progress, error, stop, info);
                
            });
            
        }
    };
    
    CGSize imageSize = CGSizeZero;
    
    CGFloat widthPix = targetSize.width*_screenScale;
    
    CGFloat scale = (CGFloat)asset.pixelWidth/asset.pixelHeight;
    
    CGFloat heightPix = targetSize.height == MAXFLOAT ? widthPix/scale : targetSize.height*_screenScale;
    
    imageSize = CGSizeMake(widthPix, heightPix);
    
    PHImageRequestID imageRequestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        //判断是否请求完成
        BOOL requestSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        
        if (requestSuccess && complete) {
            
            complete(image, info, [[info valueForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        
        if ([[info valueForKey:PHImageResultIsInCloudKey] boolValue]) {
            NSLog(@"download from iCloud");
        }
        
    }];
    
    return imageRequestID;
}

- (PHImageRequestID)requestGifImageForAsset:(PHAsset *)asset complete:(void (^)(UIImage *, NSDictionary *))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler {

    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionOriginal;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //iCloud
        if (progressHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                progressHandler(progress, error, stop, info);
            });
        }
    };
    
    PHImageRequestID phImageRequestID = [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
        //判断是否请求完成
        BOOL requestSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        
        if (requestSuccess && complete) {
            
            UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
            
            complete(image, info);
        }
        
       
    }];
    
    return phImageRequestID;
}

#warning 进度加载有问题
- (void)requestVideoDataForAsset:(PHAsset *)asset complete:(void (^)(AVPlayerItem *, NSDictionary *))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler {

    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = YES;
    
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //iCloud
        if (progressHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                progressHandler(progress, error, stop, info);
            });
        }
    };
    
    [[PHCachingImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        //判断是否请求完成
        BOOL requestSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        
        if (requestSuccess && complete) {
            complete([AVPlayerItem playerItemWithAsset:asset], info);
        }
    }];
    
//    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
//
//        //判断是否请求完成
//        BOOL requestSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
//        
//        if (requestSuccess && complete) {
//            complete(playerItem, info);
//        }
//        
//        NSLog(@"%d",[[info objectForKey:PHImageResultIsInCloudKey] boolValue]);
//    }];
}


- (PHLivePhotoRequestID)requestLivePhotoForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize complete:(void (^)(PHLivePhoto *, NSDictionary *))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler {

    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        //iCloud
        if (progressHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                progressHandler(progress, error, stop, info);
            });
        }
    };
    
    PHLivePhotoRequestID phLivePhotoRequestID = [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        
        //判断是否请求完成
        BOOL requestSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        
        if (requestSuccess && complete) {
            
            complete(livePhoto, info);
        }
    }];
    
    return phLivePhotoRequestID;
}

- (BOOL)getAuthorizationStatus {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        //授权
        return YES;
    }
    
    return NO;
}

- (NSArray<DMAssetModel *> *)getAssetModelArrayFromResult:(PHFetchResult<PHAsset *> *)result {
    
    NSMutableArray *arrAsset = [NSMutableArray array];
    
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        DMAssetModelType type = [self getAssetMediaTypeFromAsset:asset];
        
        DMAssetModel *photoModel = [DMAssetModel assetModelWithAsset:asset medieType:type];
        
        [arrAsset addObject:photoModel];
        
    }];
    
    return arrAsset;
}

- (DMAssetModelType)getAssetMediaTypeFromAsset:(PHAsset *)asset {
    
    switch (asset.mediaType) {
        case PHAssetMediaTypeAudio:
            return DMAssetModelTypeAudio;
            break;
            
        case PHAssetMediaTypeVideo:
            return DMAssetModelTypeVideo;
            break;
            
        case PHAssetMediaTypeImage:
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive)
                return DMAssetModelTypeLivePhoto;
            
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"])
                return DMAssetModelTypeGif;
            
            return DMAssetModelTypeImage;
            
        default:
            return DMAssetModelTypeUnknow;
            break;
    }
    
    return DMAssetModelTypeUnknow;
}


- (BOOL)isExistLocallyAsset:(PHAsset *)asset {

    __block BOOL isExistLocally = YES;
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        isExistLocally = imageData ? YES : NO;
    }];
    
    return isExistLocally;
}


@end
