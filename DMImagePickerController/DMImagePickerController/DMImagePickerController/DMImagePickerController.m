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
#import <objc/runtime.h>

static void *DMAssetModelsKey = "DMAssetModelsKey";

@interface DMImagePickerController ()

@end

@implementation DMImagePickerController

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {

    _maxImagesCount = maxImagesCount;
    [DMPhotoManager shareManager].maxImagesCount = maxImagesCount;
}

- (void)setAllowCrossSelect:(BOOL)allowCrossSelect {

    _allowCrossSelect = allowCrossSelect;
    
    _allowInnerPreview = _allowCrossSelect ? NO : _allowInnerPreview;
}

- (void)setAllowInnerPreview:(BOOL)allowInnerPreview {

    _allowInnerPreview = allowInnerPreview;
    
    _allowCrossSelect = _allowInnerPreview ? NO : _allowCrossSelect;
}

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

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    id controller = self.presentingViewController;
    
    if (_allowRecordSelection) {
        //记录上一次的选择
        self.arrselected = objc_getAssociatedObject(controller, DMAssetModelsKey);
    }
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount {
    
    DMAlbumViewController *albumViewController = [[DMAlbumViewController alloc] init];
    
    if (self = [super initWithRootViewController:albumViewController]) {
        
        self.allowRecordSelection = NO;
        self.allowCrossSelect = NO;
        self.allowInnerPreview = YES;
        
        self.maxImagesCount = maxImagesCount>0?maxImagesCount:9;
        
        if ([[DMPhotoManager shareManager] getAuthorizationStatus]) {
            //授权
            
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
            lab.text = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-照片\"选项中，\n允许%@访问你的手机相册。", displayName];
            
            lab.frame = CGRectMake(10, 110, KScreen_Width-20, 60);
            
            [self.view addSubview:lab];
        }
    }
    
    return self;
}

- (void)didFinishPickingImages:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos assetModel:(NSArray<DMAssetModel *> *)assetModel {

    if (self.didFinishPickingImageWithHandle) {
        self.didFinishPickingImageWithHandle(images, infos);
    }
    
    if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:infos:)]) {
        
        [self.imagePickerDelegate imagePickerController:self didFinishPickingImages:images infos:infos];
    }
    
    id controller = self.presentingViewController;
    
    //保存已选照片的模型
    objc_setAssociatedObject(controller, DMAssetModelsKey, assetModel, OBJC_ASSOCIATION_RETAIN);
    
}

- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr {
    
    [arr addObject:assetModel];
    assetModel.index = arr.count;
    assetModel.selected = YES;
}

- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource updateArr:(NSMutableArray *)arr {
    
    NSArray *arrSelected = [NSArray arrayWithArray:arr];
    for (DMAssetModel *selectModel in arrSelected) {
        if ([selectModel.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
            
            [arr removeObject:selectModel];
            
            //重置
            assetModel.index = 0;
            assetModel.selected = NO;
            
        }
    }
    
    //更新已选数组元素下标
    [self resetAssetModelIndexForArrSelected:arr];
    
    //根据已选数组同步数据源模型
    [self syncModelFromSelectedArray:arr toDataArray:dataSource];
    
}

- (void)syncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray {
    
    for (DMAssetModel *assetModel in dataArray) {
        
        for (DMAssetModel *assetModelSelected in selectArray) {
            
            if ([assetModel.asset.localIdentifier isEqualToString:assetModelSelected.asset.localIdentifier]) {
                
                assetModel.selected = YES;
                assetModel.userInteractionEnabled = YES;
                assetModel.index = assetModelSelected.index;
                break;
            } else {
                
                assetModel.selected = NO;
                //少于照片最大张数，为可交互
                assetModel.userInteractionEnabled = self.arrselected.count< self.maxImagesCount;
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

