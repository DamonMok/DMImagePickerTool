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

/**选择完照片的回调*/
@property (nonatomic, copy)void (^didFinishPickingImageWithHandle)(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos);

/**限制选择照片的最大张数*/
@property (nonatomic, assign)NSInteger maxImagesCount;

/**跨相册选择,默认为NO
   当设置为YES，则不支持内部小图预览
 */
@property (nonatomic, assign)BOOL allowCrossSelect;

/**在【大图浏览】内显示【已选择照片】的小图列表,默认为YES
   当设置YES，则不支持跨相册选择
 */
@property (nonatomic, assign)BOOL allowInnerPreview;

/**记录上一次的选择,默认为NO:不记录*/
@property (nonatomic, assign)BOOL allowRecordSelection;

/**用户是否选择原图 Yes:原图*/
@property (nonatomic, assign)BOOL isOriginal;

@property (nonatomic, weak)id<DMImagePickerDelegate> imagePickerDelegate;

/**已选择的照片数组*/
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrselected;


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount;


/**查看代理/block是否实现*/
- (void)didFinishPickingImages:(NSArray *)images infos:(NSArray *)infos assetModel:(NSArray<DMAssetModel *> *)assetModel;


///以下添加/移除照片的方法主要涉及到DMAssetModel下标的更新
/**向已选择照片数组(arrselected)中添加元素调用的方法：1.更新assetModel的index*/
- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr;

/**从已选择照片数组(arrselected)中移除元素调用的方法：1.更新已选照片(arrselected)的index;2.同步数据源模型*/
- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource updateArr:(NSMutableArray *)arr;

/**根据selectArray同步dataArray模型*/
- (void)syncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray;


/**重新调整assetModel的index*/
- (void)resetAssetModelIndexForArrSelected:(NSArray *)arrSelected;


@end

@protocol DMImagePickerDelegate <NSObject>

@optional
- (void)imagePickerController:(DMImagePickerController *)imagePicker didFinishPickingImages:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos;

@end

