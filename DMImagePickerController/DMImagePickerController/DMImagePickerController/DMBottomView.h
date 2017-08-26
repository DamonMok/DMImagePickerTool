//
//  DMBottomView.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@protocol DMBottomViewDelegate <NSObject>

@optional

//预览
- (void)bottomViewDidClickPreviewButton;

//原图
- (void)bottomViewDidClickOriginalPicture:(UIButton *)originalPictureBtn;

//发送
- (void)bottomViewDidClickSendButton;

//内部预览小图点击
- (void)bottomViewDidSelectImageWithAssetModel:(DMAssetModel *)assetModel;

@end

@interface DMBottomView : UIView

/**设置原图选中状态 YES:选中*/
@property (nonatomic, assign)BOOL isOriginal;

/**Yes:隐藏预览按钮，显示编辑按钮*/
@property (nonatomic, assign)BOOL showEditButton;

/**已选照片张数*/
@property (nonatomic, assign)NSInteger count;

/**当已选照片张数为零,发送按钮是否可以点击   YES:可以点击*/
@property (nonatomic, assign)BOOL sendEnable;

/**如果是视频，则只显示发送按钮*/
@property (nonatomic, assign)BOOL isVideo;

/**是否显示内部预览*/
@property (nonatomic, assign)BOOL showInnerPreview;
@property (nonatomic, strong)NSArray *arrData;//数据
//当前被选中的模型
@property (nonatomic, strong)DMAssetModel *selectedAssetModel;


@property (nonatomic, assign)id<DMBottomViewDelegate> delegate;

- (void)scrollToItemOfIndex:(int)index;

@end

@interface DMInnerPreviewCell : UICollectionViewCell

@property (nonatomic, strong)DMAssetModel *assetModel;

@end
