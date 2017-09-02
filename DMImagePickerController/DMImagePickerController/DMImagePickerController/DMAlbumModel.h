//
//  DMAlbumModel.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class DMAssetModel;

@interface DMAlbumModel : NSObject

/**相册标题*/
@property (nonatomic, copy)NSString *albumTitle;

/**相册包含照片数量*/
@property (nonatomic, assign)NSInteger count;

/**相册第一张封面图*/
@property (nonatomic, strong)PHAsset *coverImageAsset;

/**相册唯一标识符*/
@property (nonatomic, copy)NSString *localIdentifier;

/**相册里面的PHAsset集合*/
@property (nonatomic, strong)PHFetchResult<PHAsset *> *result;


/**
 相册模型转换
 @param title 标题
 @param localIdentifier 唯一标识
 @param result PHAsset集合
 @return 相册模型
 */
+ (instancetype)albumModelWithTitle:(NSString *)title localIdentifier:(NSString *)localIdentifier assetResult:(PHFetchResult<PHAsset *> *)result;

@end

typedef NS_ENUM(NSUInteger, DMAssetModelType) {
    
    DMAssetModelTypeImage,      //图片
    DMAssetModelTypeGif,        //gif
    DMAssetModelTypeLivePhoto,  //livePhoto
    DMAssetModelTypeVideo,      //视频
    DMAssetModelTypeAudio,      //语音
    DMAssetModelTypeUnknow      //未知
    
};

@interface DMAssetModel : NSObject

@property (nonatomic, strong)PHAsset *asset;

/**类型*/
@property (nonatomic, assign)DMAssetModelType type;

/**选中状态 YES：选中   NO：未选中*/
@property (nonatomic, assign)BOOL selected;

/**属于第几个被选中,从1开始*/
@property (nonatomic, assign)NSInteger index;

/**是否可以交互，用于超过最大图片张数的时候控制交互*/
@property (nonatomic, assign)BOOL userInteractionEnabled;

/**是否显示边框，用于内部小图预览边框是否显示*/
@property (nonatomic, assign)BOOL clicked;

+ (instancetype)assetModelWithAsset:(PHAsset *)asset medieType:(DMAssetModelType)type;

@end
