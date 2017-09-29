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
    
    if (result.count > 0) {
        
        if ([DMPhotoManager shareManager].sortAscendingByCreationDate) {
            albumModel.coverImageAsset = result.lastObject;
        } else {
            albumModel.coverImageAsset = result.firstObject;
        }

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
    
    if (asset.duration > 0) {
        
        assetModel.durationTime = [assetModel durationTimeWithSecond:asset.duration];
    }
    
    return assetModel;
}

#pragma mark 时间转化
- (NSString *)durationTimeWithSecond:(double)second {
    
    NSString *strTime;
        
    if (second < 60) {
        
        strTime = [NSString stringWithFormat:@"00:%02.0f", second];
    } else if (second < 3600) {
        
        strTime = [NSString stringWithFormat:@"%02.0f:%02.0f",second/60, fmod(second, 60)];
    } else if (second >= 3600) {
        
        strTime = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f",second/3600, second/60-second/3600*60, fmod(second, 60)];
    }
    
    return strTime;
}


@end
