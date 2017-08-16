//
//  DMImagePickerController.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@interface DMImagePickerController : UINavigationController


/**默认记录之前相册选择的照片，设置为NO则不记录*/
@property (nonatomic, assign)BOOL recordPreviousSelections;

/**用户是否选择原图*/
@property (nonatomic, assign)BOOL selectedOriginalPicture;

/**已选择的照片数组*/
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrselected;


- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount;


///以下添加/移除照片的方法主要涉及到DMAssetModel下标的更新
/**向已选择照片数组(arrselected)中添加元素调用的方法：1.更新assetModel的index*/
- (void)addAssetModel:(DMAssetModel *)assetModel;

/**从已选择照片数组(arrselected)中移除元素调用的方法：1.更新已选照片(arrselected)的index;2.同步数据源模型*/
- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource;

/**根据selectArray同步dataArray模型*/
- (void)syncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray;


/**当从已选照片数组中删除元素后，重新调整assetModel的index*/
- (void)resetAssetModelIndexForArrSelected:(NSArray *)arrSelected;


@end
