//
//  DMThumbnailController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMThumbnailController.h"
#import "DMThumbnailCell.h"
#import "DMBottomView.h"
#import "DMImagePickerController.h"
#import "DMPreviewController.h"

#define numberOfColumns 4
#define margin 4

static NSString *reusedID = @"thumbnail";

@interface DMThumbnailController ()<UICollectionViewDelegate, UICollectionViewDataSource, DMThumbnailCellDelegate, DMBottomViewDelegate, PHPhotoLibraryChangeObserver> {
    
    DMImagePickerController *_imagePickerVC;
}

//push进来传进来的数组
@property (nonatomic, strong)NSMutableArray<DMAssetModel *> *arrAssetModel;

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)DMBottomView *bottomView;

@end

@implementation DMThumbnailController

#pragma mark - lazy load

- (NSMutableArray<DMAssetModel *> *)arrAssetModel {
    
    if (!_arrAssetModel) {
        _arrAssetModel = [NSMutableArray array];
    }
    
    return _arrAssetModel;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        CGFloat itemWH = (KScreen_Width - (numberOfColumns+1)*margin)/numberOfColumns;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWH, itemWH);
        flowLayout.minimumLineSpacing = margin;
        flowLayout.minimumInteritemSpacing = margin;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreen_Width, KScreen_Height) collectionViewLayout:flowLayout];
    }
    
    return _collectionView;
}

- (DMBottomView *)bottomView {
    
    if (!_bottomView) {
        _bottomView = [[DMBottomView alloc] initWithFrame:CGRectMake(0, KScreen_Height-bottomViewHeight, KScreen_Width, bottomViewHeight)];
    }
    
    return _bottomView;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self fetchData];
    
    [self initNavigationBar];
    [self initCollectionView];
    [self initBottomView];
    [self scrollToBotton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshBottomView];
    
    [self syncAndReloadData];
    
    //相册本地+iCloud内容变化监听
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)dealloc {

    if (!_imagePickerVC.recordPreviousSelections) {
        [_imagePickerVC.arrselected removeAllObjects];
    }
    
    NSLog(@"%s", __func__);
}

#pragma mark - 获取数据
- (void)fetchData {
    
    _imagePickerVC = (DMImagePickerController *)self.navigationController;
    
        if (!_isFromTapAlbum) {
            //首次进入相册，显示所有的照片
            [[DMPhotoManager shareManager] getCameraRollAlbumCompletion:^(DMAlbumModel *albumModel) {
                
                self.albumModel = albumModel;
                self.arrAssetModel = (NSMutableArray *)[[DMPhotoManager shareManager] getAssetModelArrayFromResult:albumModel.result];
                
                    [self syncAndReloadData];
                
            }];
        } else {
            //通过点击相册进来
            self.arrAssetModel = (NSMutableArray *)[[DMPhotoManager shareManager] getAssetModelArrayFromResult:self.albumModel.result];
            
                [self syncAndReloadData];
            
        };
    
}

#pragma mark - 相册内容发生改变的监听(iCloud)
- (void)updateAlbumContent:(NSNotification *)notification {

    self.albumModel = [notification.userInfo valueForKey:@"album"];
    
    [self fetchData];
}

#pragma mark - 初始化导航栏
- (void)initNavigationBar {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    backBtn.frame = CGRectMake(-5, 0, 48, 30);
    backBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    [backBtn addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [backView addSubview:backBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cancelBtn.frame = CGRectMake(5, 0, 48, 30);
    [cancelBtn addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
    [rightView addSubview:cancelBtn];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
}

#pragma mark - 初始化底部栏
- (void)initBottomView {
    
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
}

#pragma mark - 初始化collectionView
- (void)initCollectionView {
    
    self.collectionView.contentInset = UIEdgeInsetsMake(margin+64, margin, margin+bottomViewHeight, margin);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[DMThumbnailCell class] forCellWithReuseIdentifier:reusedID];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
    
}

#pragma mark 滚到底部
- (void)scrollToBotton {
    
    if ([DMPhotoManager shareManager].sortAscendingByCreationDate) {
        
        if (self.arrAssetModel.count <= 0) return;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.arrAssetModel.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

#pragma mark 导航栏按钮
//返回
- (void)didClickBackButton {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//取消
- (void)didClickCancelButton {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 刷新底部栏状态
- (void)refreshBottomView {
    
    self.bottomView.count = _imagePickerVC.arrselected.count;
    
    self.bottomView.isOriginal = _imagePickerVC.isOriginal;
}

#pragma mark - 同步并刷新数据
- (void)syncAndReloadData {

    //同步模型
    [_imagePickerVC syncModelFromSelectedArray:_imagePickerVC.arrselected toDataArray:self.arrAssetModel];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrAssetModel.count;
}

- (DMThumbnailCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMAssetModel *assetModel = self.arrAssetModel[indexPath.row];
    
    DMThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedID forIndexPath:indexPath];
    cell.delegate = self;
    cell.assetModel = assetModel;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMAssetModel *assetModel = self.arrAssetModel[indexPath.row];
    
    if (![[DMPhotoManager shareManager] isExistLocallyAsset:assetModel.asset]) {
        
        NSLog(@"不存在");
        return;
    }
    
    if (!assetModel.userInteractionEnabled) return;
    
    DMPreviewController *previewVC = [[DMPreviewController alloc] init];
    previewVC.arrAssetModel = self.arrAssetModel;
    previewVC.selectedIndex = indexPath.row;
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark - DMThumbnailCell代理方法
#pragma mark 选择/取消选择图片
- (void)thumbnailCell:(DMThumbnailCell *)cell DidClickSelecteButtonWithAsset:(DMAssetModel *)assetModel {
    
    if (!assetModel.selected) {
        //添加到已选数组
        if (_imagePickerVC.arrselected.count >= _imagePickerVC.maxImagesCount) {
        
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)_imagePickerVC.maxImagesCount] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:action];
            [self.navigationController presentViewController:alertVC animated:YES completion:nil];
            return;
        }
        
        [_imagePickerVC addAssetModel:assetModel];
        
        if (_imagePickerVC.arrselected.count == _imagePickerVC.maxImagesCount) {
            //发送通知添加蒙版
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationShowCover" object:nil];
        }
        
    } else {
        //移除
        if (_imagePickerVC.arrselected.count == _imagePickerVC.maxImagesCount) {
            //发送通知移除蒙版
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationShowCover" object:nil userInfo:@{@"remove":@"remove"}];
        }
        
        [_imagePickerVC removeAssetModel:assetModel FromDataSource:self.arrAssetModel];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationSelectionIndexChanged" object:nil];
    
    [self refreshBottomView];
    
}

#pragma mark - DMBottomView代理方法
#pragma mark 点击预览按钮
- (void)bottomViewDidClickPreviewButton {

    DMPreviewController *previewVC = [[DMPreviewController alloc] init];
    previewVC.arrAssetModel = [_imagePickerVC.arrselected copy];
    previewVC.selectedIndex = 0;
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark 点击原图按钮
- (void)bottomViewDidClickOriginalPicture:(UIButton *)originalPictureBtn {
    
    _imagePickerVC.isOriginal = originalPictureBtn.selected;
}

- (void)bottomViewDidClickSendButton {

    NSArray *arrSelected = _imagePickerVC.arrselected;
    BOOL isOriginal = _imagePickerVC.isOriginal;
    
    NSMutableArray *arrImage = [NSMutableArray array];
    NSMutableArray *arrInfo = [NSMutableArray array];

    for (int i = 0; i < _imagePickerVC.arrselected.count; i++) {
        
        //因为获取图片是异步，所以预设一个数组，根据回调时候的i进行有序替换
        [arrImage addObject:@"placeholder"];
        [arrInfo addObject:@"placeholder"];
    }
    
    for (int i = 0; i < arrSelected.count; i++) {
        
        DMAssetModel *assetModel = arrSelected[i];
        
        [[DMPhotoManager shareManager] requestTargetImageForAsset:assetModel.asset isOriginal:isOriginal complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
            
            if (isDegraded) return ;
            
            [arrImage replaceObjectAtIndex:i withObject:image];
            [arrInfo replaceObjectAtIndex:i withObject:info];
            
            for (id asset in arrImage) {
                if ([asset isKindOfClass:[NSString class]]) return;
            }
            
            if (_imagePickerVC.didFinishPickImageWithHandle) {
                _imagePickerVC.didFinishPickImageWithHandle(arrImage, arrInfo);
            }
        }];
    }
}

#pragma mark - 相册本地+iCloud监听
/**
 官方文档示例代码
 https://developer.apple.com/documentation/photos/phphotolibrarychangeobserver?language=objc
 */
- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    // Photos may call this method on a background queue;
    // switch to the main queue to update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Check for changes to the list of assets (insertions, deletions, moves, or updates).
        PHFetchResultChangeDetails *collectionChanges = [changeInfo changeDetailsForFetchResult:self.albumModel.result];
        if (collectionChanges) {
            //获取新的PHAsset集合
            self.albumModel.result = collectionChanges.fetchResultAfterChanges;
            
            if (collectionChanges.hasIncrementalChanges)  {
                // Tell the collection view to animate insertions/deletions/moves
                // and to refresh any cells that have changed content.
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removed = collectionChanges.removedIndexes;
                    if (removed.count) {
                        //删除
                        [removed enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                            //已选数组的属性同步
                            [_imagePickerVC removeAssetModel:self.arrAssetModel[idx] FromDataSource:self.arrAssetModel];
                        }];
                        
                        [self.arrAssetModel removeObjectsAtIndexes:removed];
                        
                        [self.collectionView deleteItemsAtIndexPaths:[self indexPathsFromIndexSet:removed]];
                        
                    }
                    NSIndexSet *inserted = collectionChanges.insertedIndexes;
                    if (inserted.count) {
                        //插入
                        NSMutableArray *arrNewAssetModel = (NSMutableArray *)[[DMPhotoManager shareManager] getAssetModelArrayFromResult:self.albumModel.result];
                        NSArray *arrInsert = [arrNewAssetModel objectsAtIndexes:inserted];
                        [self.arrAssetModel insertObjects:arrInsert atIndexes:inserted];
                        
                        if (_imagePickerVC.arrselected.count == _imagePickerVC.maxImagesCount) {
                            //判断是否已经等于最大可选数量，如果是，则插入进来的元素不可交互
                            [arrInsert enumerateObjectsUsingBlock:^(DMAssetModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                
                                obj.userInteractionEnabled = NO;
                            }];
                        }
                        
                        [self.collectionView insertItemsAtIndexPaths:[self indexPathsFromIndexSet:inserted]];
                    }
                    
                } completion:^(BOOL finished) {
                    
                    if (finished) {
                        //批处理成功
//                        [self.collectionView reloadData];
                    }
                }];
                
            } else {
                // Detailed change information is not available;
                // repopulate the UI from the current fetch result.
                [self.collectionView reloadData];
            }
            
        }
        
    });
    
    
}

#pragma mark NSIndexSet -> NSIndexPath array
- (NSArray *)indexPathsFromIndexSet:(NSIndexSet *)indexSet {

    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        
        [indexPaths addObject:indexPath];
        
    }];
    
    return indexPaths;
}

@end
