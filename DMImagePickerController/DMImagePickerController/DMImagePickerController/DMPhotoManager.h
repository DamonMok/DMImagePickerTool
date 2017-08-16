//
//  DMPhotoManager.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DMAlbumModel.h"

@interface DMPhotoManager : NSObject

+ (instancetype)shareManager;

/**默认不隐藏空的相册*/
@property(nonatomic, assign)BOOL hideEmptyAlbum;

/**默认显示【已隐藏】相册*/
@property(nonatomic, assign)BOOL showHiddenAlbum;

/**默认照片根据日期升序排列*/
@property(nonatomic, assign)BOOL sortAscendingByCreationDate;

/**获取相册权限状态*/
- (BOOL)getAuthorizationStatus;

/**获取所有相册*/
- (void)getAllAlbumsCompletion:(void(^)(NSArray<DMAlbumModel *> *))completion;

/**获取Camera roll相册*/
- (void)getCameraRollAlbumCompletion:(void(^)(DMAlbumModel *))completion;

/**在DMAlbumModel模型里面提取DMAssetModel数组*/
- (NSArray<DMAssetModel *> *)getAssetModelArrayFromAlbumModel:(DMAlbumModel *)albumModel;

/**通过PHAsset请求照片*/
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetWidth:(CGFloat)width complete:(void(^)(UIImage *, NSDictionary *))completion;

/**获取相册封面图*/
- (PHImageRequestID)requestCoverImageWithAlbumModel:(DMAlbumModel *)albumModel completion:(void(^)(UIImage *, NSDictionary *))completion;



@end
