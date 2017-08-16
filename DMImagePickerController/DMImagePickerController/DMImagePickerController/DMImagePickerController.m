//
//  DMImagePickerController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMImagePickerController.h"
#import "DMAlbumViewController.h"
#import "DMThumbnailController.h"
#import "DMPhotoManager.h"
#import "DMDefine.h"

@interface DMImagePickerController ()

@end

@implementation DMImagePickerController

- (NSMutableArray<DMAssetModel *> *)arrselected {
    
    if (!_arrselected) {
        
        _arrselected = [NSMutableArray array];
        
    }
    
    return _arrselected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount {
    
    DMAlbumViewController *albumViewController = [[DMAlbumViewController alloc] init];
    
    if (self = [super initWithRootViewController:albumViewController]) {
        
        self.recordPreviousSelections = YES;
        
        if ([[DMPhotoManager shareManager] getAuthorizationStatus]) {
            //授权
            [albumViewController initTableView];
            
            DMThumbnailController *thumbnailController = [[DMThumbnailController alloc] init];
            
            [self pushViewController:thumbnailController animated:YES];
            
        } else {
            
            NSString *displayName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            UILabel *lab = [[UILabel alloc] init];
            lab.numberOfLines = 0;
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor blackColor];
            lab.font = [UIFont systemFontOfSize:14.0];
            [lab sizeToFit];
            lab.text = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中，\n允许%@访问你的手机相册。", displayName];
            
            lab.frame = CGRectMake(10, 110, KScreen_Width-20, 60);
            
            [self.view addSubview:lab];
        }
    }
    
    return self;
}

- (void)addAssetModel:(DMAssetModel *)assetModel {
    
    [self.arrselected addObject:assetModel];
    assetModel.index = self.arrselected.count;
    assetModel.selected = YES;
}

- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource {
    
    NSArray *arrSelected = [NSArray arrayWithArray:self.arrselected];
    for (DMAssetModel *selectModel in arrSelected) {
        if ([selectModel.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
            
            [self.arrselected removeObject:selectModel];
            
            //重置
            assetModel.index = 0;
            assetModel.selected = NO;
            
            //更新已选数组元素下标
            [self resetAssetModelIndexForArrSelected:self.arrselected];
            
            //根据已选数组同步数据源模型
            [self asyncModelFromSelectedArray:self.arrselected toDataArray:dataSource];
        }
    }
    
}

- (void)asyncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray {
    
    for (DMAssetModel *assetModel in dataArray) {
        
        for (DMAssetModel *assetModelSelected in selectArray) {
            
            if ([assetModel.asset.localIdentifier isEqualToString:assetModelSelected.asset.localIdentifier]) {
                
                assetModel.selected = YES;
                assetModel.index = assetModelSelected.index;
                break;
            } else {
                
                assetModel.selected = NO;
            }
        }
    }
}

- (void)resetAssetModelIndexForArrSelected:(NSArray *)arrSelected {
    
    for (int i=0; i<arrSelected.count; i++) {
        
        DMAssetModel *assetModel = arrSelected[i];
        assetModel.index = i+1;
    }
}




@end

