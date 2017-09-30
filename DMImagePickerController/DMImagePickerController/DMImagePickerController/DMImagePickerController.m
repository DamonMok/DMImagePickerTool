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

/**记录上一次选择的模型数组*/
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrRecord;

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
        self.arrRecord = objc_getAssociatedObject(controller, DMAssetModelsKey);
        self.arrselected = [self.arrRecord mutableCopy];
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

- (void)didFinishPickingImages:(NSArray<UIImage *> *)images infos:(NSArray<NSDictionary *> *)infos assetModels:(NSArray<DMAssetModel *> *)assetModels {

    if (self.didFinishPickingImageWithHandle) {
        self.didFinishPickingImageWithHandle(images, infos, [assetModels mutableCopy]);
    }
    
    if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:infos:)]) {
        
        [self.imagePickerDelegate imagePickerController:self didFinishPickingImages:images infos:infos];
    }
    
    id controller = self.presentingViewController;
    
    //保存已选照片的模型
    objc_setAssociatedObject(controller, DMAssetModelsKey, [assetModels mutableCopy], OBJC_ASSOCIATION_RETAIN);
    
}

//删除已经不存在的记录(每次打开相册的时候调用)
- (void)deleteExtraRecordModelByAllModels:(NSMutableArray *)arrAll {

    __block BOOL isFind = NO;
    [_arrRecord enumerateObjectsUsingBlock:^(DMAssetModel * _Nonnull recordAssetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        isFind = NO;
        
        [arrAll enumerateObjectsUsingBlock:^(DMAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([recordAssetModel.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                
                isFind = YES;
            }
        }];
        
        if (!isFind) {
            
            //删除不存在的记录
            [self.arrRecord removeObject:recordAssetModel];
            [self.arrselected removeObject:recordAssetModel];
        }
    }];
    
    //更新下标
    [self resetAssetModelIndexForArrSelected:_arrselected];
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

