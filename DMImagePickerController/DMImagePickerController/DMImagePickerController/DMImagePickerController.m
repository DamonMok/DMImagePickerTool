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
#import "DMDefine.h"
#import <objc/runtime.h>
#import "DMPhotoManager.h"

static void *DMAssetModelsKey = "DMAssetModelsKey";

@interface DMImagePickerController ()<UIGestureRecognizerDelegate>

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

- (void)setSortAscendingByCreationDate:(BOOL)sortAscendingByCreationDate {

    _sortAscendingByCreationDate = sortAscendingByCreationDate;
    
    [DMPhotoManager shareManager].sortAscendingByCreationDate = sortAscendingByCreationDate;
}

- (void)setAllowImage:(BOOL)allowImage {

    _allowImage = allowImage;
    
    [DMPhotoManager shareManager].allowImage = allowImage;
}

- (void)setAllowGif:(BOOL)allowGif {

    _allowGif = allowGif;
    
    [DMPhotoManager shareManager].allowGif = allowGif;
}

- (void)setAllowLivePhoto:(BOOL)allowLivePhoto {

    _allowLivePhoto = allowLivePhoto;
    
    [DMPhotoManager shareManager].allowLivePhoto = allowLivePhoto;
}

- (void)setAllowVideo:(BOOL)allowVideo {

    _allowVideo = allowVideo;
    
    [DMPhotoManager shareManager].allowVideo = allowVideo;
}

- (void)setShowVideoAsImage:(BOOL)showVideoAsImage {

    _showVideoAsImage = showVideoAsImage;
    
    [DMPhotoManager shareManager].showVideoAsImage = showVideoAsImage;
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    
    _maxImagesCount = maxImagesCount;
    
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
    
    //解决右滑返回失效
    self.interactivePopGestureRecognizer.delegate = self;
    
    self.allowRadio = NO;
    self.allowCrossSelect = NO;
    self.allowInnerPreview = YES;
    self.allowRecordSelection = YES;
    
    self.allowVideo = YES;
    self.allowImage = YES;
    self.allowGif = YES;
    self.allowLivePhoto = YES;
    self.showVideoAsImage = NO;
    self.sortAscendingByCreationDate = YES;
    
    self.maxImagesCount = _maxImagesCount>0?_maxImagesCount:9;
    
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

#pragma mark - 选择照片完成/取消 回调
//选择照片完成回调
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

//取消选择照片回调
- (void)didCancelPickingImage {

    if (self.didCancelPickingImageWithHandle) {
        
        self.didCancelPickingImageWithHandle();
    }
    
    if ([self.imagePickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        
        [self.imagePickerDelegate imagePickerControllerDidCancel:self];
    }
}

#pragma mark - 数据处理
// 删除已经不存在的记录(每次打开相册的时候调用)
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

//新增
- (void)addAssetModel:(DMAssetModel *)assetModel updateArr:(NSMutableArray *)arr {
    
    if (_allowRadio) {
        //单选
        if (arr.count >= 1) {
            
            DMAssetModel *exModel = arr[0];
            exModel.index = 0;
            exModel.selected = NO;
            
            [arr replaceObjectAtIndex:0 withObject:assetModel];
            
        } else {
        
            [arr addObject:assetModel];
        }
        
        assetModel.index = 1;
        assetModel.selected = YES;
        
        return;
    }
    
    //多选
    [arr addObject:assetModel];
    assetModel.index = arr.count;
    assetModel.selected = YES;
}

//删除
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

//根据已选择数组同步模型数组
- (void)syncModelFromSelectedArray:(NSMutableArray<DMAssetModel *> *)selectArray toDataArray:(NSArray<DMAssetModel *> *)dataArray {
    
    NSMutableArray *arrSelected = selectArray;
    
    for (DMAssetModel *assetModel in dataArray) {
        
        if (selectArray.count == 0) {
            //已选择照片数组为0，不需要同步，属性重置
            assetModel.selected = NO;
            assetModel.index = 0;
            assetModel.userInteractionEnabled = YES;
            
            continue;
        }
        
        for (DMAssetModel *assetModelSelected in arrSelected) {
            //已选择照片数组>0，同步
            if ([assetModel.asset.localIdentifier isEqualToString:assetModelSelected.asset.localIdentifier]) {
                
                assetModel.selected = YES;
                assetModel.index = [selectArray indexOfObject:assetModelSelected]+1;
                assetModel.userInteractionEnabled = YES;
                
                assetModelSelected.selected = YES;
                assetModelSelected.index = [selectArray indexOfObject:assetModelSelected]+1;
                assetModelSelected.userInteractionEnabled = YES;
                
                if (_allowRadio) {
                    //单选元素同步
                    [selectArray replaceObjectAtIndex:0 withObject:assetModel];
                }
                
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

#pragma mark 右滑返回判断
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    return self.childViewControllers.count > 1;
}


@end

