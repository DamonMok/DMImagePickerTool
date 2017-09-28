//
//  DMImagePickerController.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

//typedef void(^didFinishPickImage)(NSArray<UIImage *> *, NSArray<NSDictionary *> *);

@interface DMImagePickerController : UINavigationController

@property (nonatomic, copy)void (^didFinishPickImageWithHandle)(NSArray<UIImage *> *images, NSArray<NSDictionary *> *infos);

/**限制选择照片的最大张数*/
@property (nonatomic, assign)NSInteger maxImagesCount;

/**跨相册选择,YES为开启*/
@property (nonatomic, assign)BOOL allowCrossSelect;

/**在【大图浏览内】显示【已选择的内部小图】预览,
   默认为YES
   当支持跨相册选择(allowCrossSelect=YES)时，则不支持内部预览
 */
@property (nonatomic, assign)BOOL allowInnerPreview;

/**用户是否选择原图 Yes:原图*/
@property (nonatomic, assign)BOOL isOriginal;

/**已选择的照片数组*/
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrselected;


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount;


///以下添加/移除照片的方法主要涉及到DMAssetModel下标的更新
/**向已选择照片数组(arrselected)中添加元素调用的方法：1.更新assetModel的index*/
- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr;

/**从已选择照片数组(arrselected)中移除元素调用的方法：1.更新已选照片(arrselected)的index;2.同步数据源模型*/
- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource updateArr:(NSMutableArray *)arr;

/**根据selectArray同步dataArray模型*/
- (void)syncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray;


/**当从已选照片数组中删除元素后，重新调整assetModel的index*/
- (void)resetAssetModelIndexForArrSelected:(NSArray *)arrSelected;


@end
