//
//  DMThumbnailCell.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAlbumModel.h"

@class DMThumbnailCell;

@protocol DMThumbnailCellDelegate <NSObject>

@optional
- (void)thumbnailCell:(DMThumbnailCell *)cell DidClickSelecteButtonWithAsset:(DMAssetModel *)assetModel;

@end

@interface DMThumbnailCell : UICollectionViewCell


@property (nonatomic, strong)DMAssetModel *assetModel;

@property (nonatomic, assign)id<DMThumbnailCellDelegate> delegate;

- (void)updateSelectedIndex:(NSInteger)index;

@end
