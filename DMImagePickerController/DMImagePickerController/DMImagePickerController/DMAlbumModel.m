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

+ (instancetype)albumModelWithCollection:(PHAssetCollection *)collection assetResult:(PHFetchResult<PHAsset *> *)result {

    DMAlbumModel *albumModel = [[DMAlbumModel alloc] init];
    
    albumModel.albumTitle = collection.localizedTitle;
    albumModel.count = result.count;
    albumModel.result = result;
    albumModel.collection = collection;
    
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
