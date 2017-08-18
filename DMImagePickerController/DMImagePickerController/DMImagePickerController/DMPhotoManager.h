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

/**默认返回照片的最大宽度为414*/
@property(nonatomic, assign)CGFloat maxWidth;

/**限制选择照片的最大张数*/
@property(nonatomic, assign)NSInteger maxImagesCount;


/**获取相册权限状态*/
- (BOOL)getAuthorizationStatus;

/**获取所有相册*/
- (void)getAllAlbumsCompletion:(void(^)(NSArray<DMAlbumModel *> *))completion;

/**获取Camera roll相册*/
- (void)getCameraRollAlbumCompletion:(void(^)(DMAlbumModel *))completion;

/**在DMAlbumModel模型里面提取DMAssetModel数组*/
- (NSArray<DMAssetModel *> *)getAssetModelArrayFromAlbumModel:(DMAlbumModel *)albumModel;

/**
 获取相册封面图
 @param albumModel 相册模型
 @param complete 回调
 @return 图片异步请求标识符
 */
- (PHImageRequestID)requestCoverImageWithAlbumModel:(DMAlbumModel *)albumModel complete:(void (^)(UIImage *, NSDictionary *))complete;

- (PHImageRequestID)requestImageFoarAsset:(PHAsset *)asset complete:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))complete;

/**
 通过PHAsset请求照片
 @param asset PHAsset
 @param targetSize 照片尺寸，当传入的height=MAXFLOAT的时候：根据宽度进行高度自适应
 @param complete 回调
 @return 图片异步请求标识符
 */
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize complete:(void(^)(UIImage *, NSDictionary *, BOOL isDegraded))complete;

- (PHImageRequestID)requestImageDataForAsset:(PHAsset *)asset complete:(void(^)(NSData *, NSDictionary *))complete;



@end
