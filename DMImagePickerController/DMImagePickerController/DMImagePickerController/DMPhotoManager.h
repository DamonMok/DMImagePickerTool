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

/**默认隐藏空的相册*/
@property(nonatomic, assign)BOOL showEmptyAlbum;

/**默认隐藏【已隐藏】相册*/
@property(nonatomic, assign)BOOL showHiddenAlbum;

/**默认照片根据日期升序排列*/
@property(nonatomic, assign)BOOL sortAscendingByCreationDate;

/**默认返回照片的最大宽度为414*/
@property(nonatomic, assign)CGFloat maxWidth;


/**是否允许选择照片*/
@property (nonatomic, assign)BOOL allowImage;

/**是否允许选择Gif。当设置为NO，Gif将以照片形式显示*/
@property (nonatomic, assign)BOOL allowGif;

/**是否允许选择Livephoto。当设置为NO，LivePhoto将以照片形式显示*/
@property (nonatomic, assign)BOOL allowLivePhoto;

/**是否允许选择视频*/
@property (nonatomic, assign)BOOL allowVideo;

/**是否将视频以照片的形式显示*/
@property (nonatomic, assign)BOOL showVideoAsImage;

/**获取所有相册*/
- (void)getAllAlbumsCompletion:(void(^)(NSArray<DMAlbumModel *> *))completion;

/**获取Camera roll相册*/
- (void)getCameraRollAlbumCompletion:(void(^)(DMAlbumModel *))completion;



/**
 返回给用户的图片

 @param asset PHAsset
 @param isOriginal 是否需要原图
 @param complete 返回的照片不大于默认宽度414pt
 @return 请求照片的标识
 */
- (PHImageRequestID)requestTargetImageForAsset:(PHAsset *)asset isOriginal:(BOOL)isOriginal complete:(void (^)(UIImage *image, NSDictionary *info, BOOL isDegraded))complete;

- (PHImageRequestID)requestTargetGifForAsset:(PHAsset *)asset complete:(void (^)(UIImage *image, NSDictionary *info))complete;

- (PHImageRequestID)requestTargetLivePhotoForAsset:(PHAsset *)asset complete:(void(^)(PHLivePhoto *livePhoto, NSDictionary *info))complete;

/**
 获取相册封面图
 @param albumModel 相册模型
 @param complete 回调
 @return 图片异步请求标识符
 */
- (PHImageRequestID)requestPosterImageWithAlbumModel:(DMAlbumModel *)albumModel complete:(void (^)(UIImage *, NSDictionary *))complete;

/**
 通过PHAsset请求照片
 @param asset PHAsset
 @param targetSize 照片尺寸，当传入的height=MAXFLOAT的时候：根据宽度进行高度自适应
 @param complete 回调
 @param progressHandler 下载进度
 @return 图片异步请求标识符
 */
- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize complete:(void (^)(UIImage *image, NSDictionary *info, BOOL isDegraded))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler;


/**
 请求Gif图片
 @param asset PHAsset
 @return 经过处理的Gif图片，可以直接传给imageView显示
 */
- (PHImageRequestID)requestGifImageForAsset:(PHAsset *)asset complete:(void(^)(UIImage *, NSDictionary *))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler;


/**
 请求视频数据
 @param asset PHAsset
 @param complete 用户可在回调中得到AVPlayerItem用来播放
 */
- (PHImageRequestID)requestVideoDataForAsset:(PHAsset *)asset complete:(void(^)(AVPlayerItem *, NSDictionary *))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler;

/**
 请求LivePhoto数据

 @param asset PHAsset
 @param targetSize 目标尺寸
 @param complete 完成回调
 @param progressHandler 进度回调
 @return 请求标识符
 */
- (PHLivePhotoRequestID)requestLivePhotoForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize complete:(void(^)(PHLivePhoto *livePhoto, NSDictionary *info))complete progressHandler:(void (^)(double progress, NSError * error, BOOL *stop, NSDictionary *info))progressHandler;


/**获取相册权限状态*/
- (BOOL)getAuthorizationStatus;

/**在DMAlbumModel模型里面提取DMAssetModel数组*/
- (NSArray<DMAssetModel *> *)getAssetModelArrayFromResult:(PHFetchResult<PHAsset *> *)result;

/**
 判断文件是否在本地
 @param asset PHAsset
 @return 是否存在本地的布尔值
 */
- (BOOL)isExistLocallyAsset:(PHAsset *)asset;


@end
