//
//  DMImagePickerController.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@protocol DMImagePickerDelegate;

@interface DMImagePickerController : UINavigationController

#pragma mark - 初始化方法
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount;

#pragma mark - 可配置参数
/**选择完照片的回调*/
@property (nonatomic, copy)void (^didFinishPickingImageWithHandle)(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos, NSArray<DMAssetModel *> *assetModels);

/**取消选择的回调*/
@property (nonatomic, copy)void (^didCancelPickingImageWithHandle)();

/**相册单选,默认为NO*/
@property (nonatomic, assign)BOOL allowRadio;

/**跨相册选择,默认为NO。当设置为YES，则不支持内部小图预览*/
@property (nonatomic, assign)BOOL allowCrossSelect;

/**在【大图浏览】内显示【已选择照片】的小图列表,默认为YES。当设置YES，则不支持跨相册选择*/
@property (nonatomic, assign)BOOL allowInnerPreview;

/**记录上一次的选择,默认为NO:不记录*/
@property (nonatomic, assign)BOOL allowRecordSelection;

#pragma mark - other
/**限制选择照片的最大张数，默认9张*/
@property (nonatomic, assign)NSInteger maxImagesCount;

/**已选择照片的模型数组*/
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrselected;

/**用户是否选择原图 YES:原图*/
@property (nonatomic, assign)BOOL isOriginal;

@property (nonatomic, weak)id<DMImagePickerDelegate> imagePickerDelegate;


#pragma mark - 内部实现调用的方法
/**查看【选择完成】代理/block是否实现*/
- (void)didFinishPickingImages:(NSArray *)images infos:(NSArray *)infos assetModels:(NSArray<DMAssetModel *> *)assetModels;

/**查看【取消选择】代理/block是否实现*/
- (void)didCancelPickingImage;

/**
 删除已经不存在的记录
 @param arrAll 所有照片的模型数组
 */
- (void)deleteExtraRecordModelByAllModels:(NSMutableArray *)arrAll;

///照片模型(DMAssetModel)数组的添加/移除照片方法
/**向已选择照片数组(arrselected)中添加元素调用的方法：1.更新assetModel的index*/
- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr;

/**从已选择照片数组(arrselected)中移除元素调用的方法：1.更新已选照片(arrselected)的index;2.同步数据源模型*/
- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource arrSelected:(NSArray *)arrSelected;

/**根据selectArray同步dataArray模型*/
- (void)syncModelFromSelectedArray:(NSMutableArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray;

@end


#pragma mark - 相关操作代理方法
@protocol DMImagePickerDelegate <NSObject>

@optional

/**选择照片完成*/
- (void)imagePickerController:(DMImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos;


/**取消选择*/
- (void)imagePickerControllerDidCancel:(DMImagePickerController *)imagePicker;

@end

