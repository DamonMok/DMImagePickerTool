//
//  DMAlbumModel.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMAlbumModel.h"
#import "DMPhotoManager.h"

@implementation DMAlbumModel

+ (instancetype)albumModelWithTitle:(NSString *)title localIdentifier:(NSString *)localIdentifier assetResult:(PHFetchResult<PHAsset *> *)result {
    
    DMAlbumModel *albumModel = [[DMAlbumModel alloc] init];
    
    albumModel.albumTitle = title;
    albumModel.localIdentifier = localIdentifier;
    albumModel.count = result.count;
    albumModel.result = result;
    
    if ([DMPhotoManager shareManager].sortAscendingByCreationDate) {
        albumModel.coverImageAsset = result.lastObject;
    } else {
        albumModel.coverImageAsset = result.firstObject;
    }
    
    return albumModel;
}

@end



@implementation DMAssetModel

+ (instancetype)assetModelWithAsset:(PHAsset *)asset medieType:(DMAssetModelType)type {
    
    DMAssetModel *assetModel = [[DMAssetModel alloc] init];
    assetModel.asset = asset;
    assetModel.type = type;
    assetModel.userInteractionEnabled = YES;
    return assetModel;
}

@end
