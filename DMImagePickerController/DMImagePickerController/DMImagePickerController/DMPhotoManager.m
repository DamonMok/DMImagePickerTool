//
//  DMPhotoManager.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoManager.h"
#import "DMDefine.h"

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
}

//6plus/6splus/7plus    屏幕宽度414 -----@3x
//非上述机型    屏幕宽度<414 -----@2x
- (void)configScreenScale {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _screenScale = screenWidth > 400 ? 3:2;
}

- (BOOL)getAuthorizationStatus {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        //授权
        return YES;
    }
    
    return NO;
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
            DMAlbumModel *albumModel = [DMAlbumModel albumModelWithTitle:collection.localizedTitle assetResult:result];
            
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
            
            DMAlbumModel *albumModel = [DMAlbumModel albumModelWithTitle:collection.localizedTitle assetResult:result];
            
            if (completion) {
                completion(albumModel);
            }
        }
    }];
    
}

- (NSArray<DMAssetModel *> *)getAssetModelArrayFromAlbumModel:(DMAlbumModel *)albumModel {
    
    NSMutableArray *arrAsset = [NSMutableArray array];
    
    [albumModel.result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        DMAssetModelType type = [self getAssetMediaTypeFromAsset:asset];
        
        DMAssetModel *photoModel = [DMAssetModel assetModelWithAsset:asset medieType:type];
        
        [arrAsset addObject:photoModel];
        
    }];
    
    return arrAsset;
}

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetWidth:(CGFloat)width complete:(void (^)(UIImage *, NSDictionary *))completion {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
    
    CGSize imageSize = CGSizeZero;
    if (width<[UIScreen mainScreen].bounds.size.width) {
        //thumbnails
        imageSize = CGSizeMake(width*_screenScale, width*_screenScale);
    } else {
        
        CGFloat widthPix = width*_screenScale;
        
        CGFloat scale = (CGFloat)asset.pixelWidth/asset.pixelHeight;
        CGFloat heightPix = widthPix/scale;
        
        imageSize = CGSizeMake(widthPix, heightPix);
    }
    
    PHImageRequestID imageRequestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        //判断是否请求完成
        BOOL downloadSuccess = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![[info objectForKey:PHImageErrorKey] boolValue];
        
        if (downloadSuccess && completion) {
            
            completion(image, info);
        }
        
    }];
    
    return imageRequestID;
}

- (PHImageRequestID)requestCoverImageWithAlbumModel:(DMAlbumModel *)albumModel completion:(void (^)(UIImage *, NSDictionary *))completion
{
    return [self requestImageForAsset:albumModel.coverImageAsset targetWidth:58.0 complete:completion];
    
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
                return DMAssetModelTypePhotoLive;
            
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"])
                return DMAssetModelTypeGif;
            
            return DMAssetModelTypeImage;
            
        default:
            return DMAssetModelTypeUnknow;
            break;
    }
    
    return DMAssetModelTypeUnknow;
}

@end
