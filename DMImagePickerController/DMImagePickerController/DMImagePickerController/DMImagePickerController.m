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

#pragma mark - lazy load
- (void)setAllowCrossSelect:(BOOL)allowCrossSelect {

    _allowCrossSelect = allowCrossSelect;
    
    _allowInnerPreview = _allowCrossSelect ? NO : _allowInnerPreview;
    
}

- (void)setAllowInnerPreview:(BOOL)allowInnerPreview {

    _allowInnerPreview = allowInnerPreview;
    
    _allowCrossSelect = _allowInnerPreview ? NO : _allowCrossSelect;
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    
    _maxImagesCount = maxImagesCount;
    
    [DMPhotoManager shareManager].maxImagesCount = maxImagesCount;
}

- (NSMutableArray<DMAssetModel *> *)arrselected {
    
    if (!_arrselected) {
        
        _arrselected = [NSMutableArray array];
        
    }
    
    return _arrselected;
}

#pragma mark - cycle
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

- (void)dealloc {

    NSLog(@"%s", __func__);
}

#pragma mark - 初始化
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

#pragma mark - 选择照片完成回调
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

#pragma mark - 取消选择照片回调
- (void)didCancelPickingImage {

    if (self.didCancelPickingImageWithHandle) {
        
        self.didCancelPickingImageWithHandle();
    }
    
    if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        
        [self.imagePickerDelegate imagePickerControllerDidCancel:self];
    }
}

#pragma mark - 数据处理
#pragma mark 删除已经不存在的记录(每次打开相册的时候调用)
- (void)deleteExtraRecordModelByAllModels:(NSMutableArray *)arrAll {

    __block BOOL isFind = NO;

    NSMutableArray *arrRecord = [NSMutableArray arrayWithArray:_arrRecord];
    
    for (DMAssetModel *recordAssetModel in arrRecord) {
        
        isFind = NO;
        
        for (DMAssetModel *assetModel in arrAll) {
            
            if ([recordAssetModel.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
                
                isFind = YES;
                break;
            }
        }
        
        if (!isFind) {
            
            //删除不存在的记录
            recordAssetModel.index = 0;
            [self.arrRecord removeObject:recordAssetModel];
            [self.arrselected removeObject:recordAssetModel];
        }
    }
    
}

#pragma mark 新增
- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr {
    
    [arr addObject:assetModel];
    assetModel.index = arr.count;
    assetModel.selected = YES;
}

#pragma mark 删除
- (void)removeAssetModel:(DMAssetModel *)assetModel FromDataSource:(NSArray *)dataSource arrSelected:(NSMutableArray *)arrSelected {
    
    NSArray *arrSlt = [NSArray arrayWithArray:arrSelected];
    for (DMAssetModel *selectModel in arrSlt) {
        if ([selectModel.asset.localIdentifier isEqualToString:assetModel.asset.localIdentifier]) {
            
            [arrSelected removeObject:selectModel];
        
        }
    }
    
    //根据已选数组同步数据源模型
    [self syncModelFromSelectedArray:arrSelected toDataArray:dataSource];
    
}

#pragma mark 根据已选择数组同步模型数组
- (void)syncModelFromSelectedArray:(NSArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray {
    
    for (DMAssetModel *assetModel in dataArray) {
        
        if (selectArray.count == 0) {
            //已选择照片数组为0，不需要同步，属性重置
            assetModel.selected = NO;
            assetModel.index = 0;
            assetModel.userInteractionEnabled = YES;
            
            continue;
        }
        
        for (DMAssetModel *assetModelSelected in selectArray) {
            //已选择照片数组>0，同步
            if ([assetModel.asset.localIdentifier isEqualToString:assetModelSelected.asset.localIdentifier]) {
                
                assetModel.selected = YES;
                assetModel.index = [selectArray indexOfObject:assetModelSelected]+1;
                assetModel.userInteractionEnabled = YES;
                
                assetModelSelected.selected = YES;
                assetModelSelected.index = [selectArray indexOfObject:assetModelSelected]+1;
                assetModelSelected.userInteractionEnabled = YES;
                
                break;
            } else {
                
                assetModel.selected = NO;
                assetModel.index = 0;
                //少于照片最大张数，为可交互
                assetModel.userInteractionEnabled = self.arrselected.count< self.maxImagesCount;

            }
        }
        
    }
}









@end

