//
//  DMPreviewController.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPreviewController.h"
#import "DMBottomView.h"
#import "DMDefine.h"
#import "DMImagePickerController.h"
#import "UIView+layout.h"
#import "DMPreviewCell.h"
#import "UIImage+category.h"
#import "UIColor+category.h"
#import "DMPhotoManager.h"


#define margin 20

static NSString *reusedImage = @"image";
static NSString *reusedGif = @"gif";
static NSString *reusedVideo = @"video";
static NSString *reusedLivePhoto = @"livePhoto";

@interface DMPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource, DMBottomViewDelegate>{
    
    DMImagePickerController *_imagePickerVC;
    NSMutableArray *_arrselected;//已选择的照片数组
    
    UIButton *_btnSelected;
    
    int _currentIndex;//当前索引
    
    DMAssetModel *_currentAssetModel;//当前模型
    
    DMPreviewCell *_currentPreviewCell;
    
}

@property (nonatomic, strong)NSArray<DMAssetModel *> *arrAssetModel;//数据源
@property (nonatomic, strong)NSArray<DMAssetModel *> *arrUpdate;//返回时赋值刷新的数据

@property (nonatomic, strong)UIView *navigationView;

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)DMBottomView *bottomView;

@property (nonatomic, assign)BOOL isFullScreen;//全屏标识

@end

@implementation DMPreviewController

//lazy load
- (void)setArrData:(NSArray *)arrData {

    _arrData = arrData;
    
    _arrAssetModel = [_arrData mutableCopy];
    
    _arrUpdate = _arrData;
}

- (UIView *)navigationView {
    
    if (!_navigationView) {
        _navigationView = [[UIView alloc] init];
        [self.view addSubview:_navigationView];
    }
    
    return _navigationView;
}

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = margin;
        layout.itemSize = self.view.frame.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, margin, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-margin, 0, KScreen_Width+margin, KScreen_Height) collectionViewLayout:layout];
    }
    
    return _collectionView;
}

- (DMBottomView *)bottomView {
    
    if (!_bottomView) {
        
        _bottomView = [[DMBottomView alloc] initWithFrame:CGRectMake(0, KScreen_Height-bottomViewHeight, KScreen_Width, bottomViewHeight)];
    }
    
    return _bottomView;
}

//cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    [self initCollectionView];
    [self initNavigationBar];
    [self initBottomView];
    [self refreshBottomView];
    [self scrollToTargetItem];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    //播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitFullScreen) name:@"didPlayToEndTime" object:nil];
    
    //开始播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFullScreen) name:@"willPlay" object:nil];
    
    //暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitFullScreen) name:@"willPause" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didPlayToEndTime" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"willPlay" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"willPause" object:nil];
    
    _imagePickerVC.arrselected = _arrselected;
    
    for (DMAssetModel *assetModel in self.arrAssetModel) {
        
        if (![self.arrUpdate containsObject:assetModel]) {
            //如果在预览大图时，系统相册某个元素被删除(触发系统相册和app相册同步)，并且在预览大图时新选择了这个元素。那么需要比较缩略图页面和预览大图页面两个数据源，在离开大图预览的时候把该元素删除。
            [_imagePickerVC.arrselected removeObject:assetModel];
        }
    }
    //更新索引
    [_imagePickerVC resetAssetModelIndexForArrSelected:_imagePickerVC.arrselected];
    
    _imagePickerVC = nil;
}

#pragma mark - 初始化自定义导航栏
- (void)initNavigationBar {
    
    self.navigationView.frame = CGRectMake(0, 0, KScreen_Width, 64);
    
    //background
    UIImageView *ivBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumPhotoImageViewBottomBK"]];
    ivBgImageView.alpha = 0.95;
    ivBgImageView.frame = CGRectMake(0, 0, KScreen_Width, 64);
    
    //backbtn
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    btnBack.frame = CGRectMake(18, 0, 30, 30);
    btnBack.dm_centerY = 64*0.5;
    [btnBack addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    //selectedBtn
    _btnSelected = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSelected setBackgroundImage:[UIImage imageNamed:@"FriendsSendsPicturesSelectBigNIcon"] forState:UIControlStateNormal];
    [_btnSelected setBackgroundImage:[UIImage imageNamed:@"FriendsSendsPicturesNumberIcon"] forState:UIControlStateSelected];
    _btnSelected.frame = CGRectMake(KScreen_Width-42-14, 0, 42, 42);
    
    _btnSelected.dm_centerY = 64*0.5;
    [_btnSelected addTarget:self action:@selector(didClickSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationView addSubview:ivBgImageView];
    [self.navigationView addSubview:btnBack];
    [self.navigationView addSubview:_btnSelected];
}

#pragma mark - 初始化collectionView
- (void)initCollectionView {
    
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.collectionView registerClass:[DMImagePreviewCell class] forCellWithReuseIdentifier:reusedImage];
    [self.collectionView registerClass:[DMGifPreviewCell class] forCellWithReuseIdentifier:reusedGif];
    [self.collectionView registerClass:[DMVideoPreviewCell class] forCellWithReuseIdentifier:reusedVideo];
    [self.collectionView registerClass:[DMLivePhotoPreviewCell class] forCellWithReuseIdentifier:reusedLivePhoto];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
    
    //注册3D Touch，判断设备是否支持
    if ([self respondsToSelector:@selector(traitCollection)]) {
        
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                
                [self registerForPreviewingWithDelegate:(id)self sourceView:self.collectionView];
            }
        }
    }
}

#pragma mark - 初始化底部栏
- (void)initBottomView {
    
    _imagePickerVC = (DMImagePickerController *)self.navigationController;
    _arrselected = [_imagePickerVC.arrselected mutableCopy];
    
    
    self.bottomView.delegate = self;
    self.bottomView.showEditButton = YES;
    self.bottomView.sendEnable = YES;
    self.bottomView.allowInnerPreview = _imagePickerVC.allowInnerPreview;
    self.bottomView.arrData = _arrselected;
    
    if (_imagePickerVC.allowInnerPreview) {
        
        self.bottomView.frame = CGRectMake(0, KScreen_Height-bottomViewHeight-KInnerPreviewHeight, KScreen_Width, bottomViewHeight+KInnerPreviewHeight);
        
        //与当前所点击进来的照片进行位置联动
        DMAssetModel *selectedModel = self.arrAssetModel[self.selectedIndex];
        for (int i = 0; i < self.bottomView.arrData.count; i++) {
            DMAssetModel *assetModel = self.bottomView.arrData[i];
            
            if ([assetModel.asset.localIdentifier isEqualToString:selectedModel.asset.localIdentifier]) {
                
                [self.bottomView scrollToItemOfIndex:i];
            }
        }
    }
    
    [self.view addSubview:self.bottomView];
    
}

#pragma mark - 滚动到目标Item
- (void)scrollToTargetItem {
    
    if (self.selectedIndex > 0) {
        //调用系统的滚动方法后，会自动调用- (void)scrollViewDidScroll:(UIScrollView *)scrollView方法
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
    } else if (self.selectedIndex == 0) {
        
        //index为0的时候，不会调用- (void)scrollViewDidScroll:(UIScrollView *)scrollView方法
        //需要根据model调整选择按钮的状态
        _currentAssetModel = self.arrAssetModel.firstObject;
        _btnSelected.selected = _currentAssetModel.selected;
        [_btnSelected setTitle:[NSString stringWithFormat:@"%ld",_currentAssetModel.index] forState:UIControlStateSelected];
        
    }
}

#pragma mark - 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - collectionView dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.arrAssetModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DMAssetModel *assetModel = self.arrAssetModel[indexPath.row];
    
    DMPreviewCell *cell;
    
    switch (assetModel.type) {
        case DMAssetModelTypeImage:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedImage forIndexPath:indexPath];
            break;
        case DMAssetModelTypeGif:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedGif forIndexPath:indexPath];
            break;
        case DMAssetModelTypeVideo:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedVideo forIndexPath:indexPath];
            break;
        case DMAssetModelTypeLivePhoto:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedLivePhoto forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    __weak typeof(self) weakself = self;
    cell.singleTap = ^{
        weakself.isFullScreen = !weakself.isFullScreen;
        
        if (weakself.isFullScreen) {
            [weakself enterFullScreen];
        } else {
            [weakself quitFullScreen];
        }
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //预加载
    DMAssetModel *assetModel = self.arrAssetModel[indexPath.row];
    switch (assetModel.type) {
        case DMAssetModelTypeImage:
            ((DMImagePreviewCell *)cell).assetModel = self.arrAssetModel[indexPath.row];
            break;
        case DMAssetModelTypeGif:
            ((DMGifPreviewCell *)cell).assetModel = self.arrAssetModel[indexPath.row];
            [((DMGifPreviewCell *)cell) resume];//播放
            break;
        case DMAssetModelTypeVideo:
            ((DMVideoPreviewCell *)cell).assetModel = self.arrAssetModel[indexPath.row];
            break;
        case DMAssetModelTypeLivePhoto:
            ((DMLivePhotoPreviewCell *)cell).assetModel = self.arrAssetModel[indexPath.row];
//            [((DMLivePhotoPreviewCell *)cell) resume];//播放
            break;
            
        default:
            break;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    DMAssetModel *assetModel = self.arrAssetModel[indexPath.row];
    
    [((DMPreviewCell *)cell) resetWith:assetModel];
    
}

#pragma mark - 刷新底部栏
- (void)refreshBottomView {
    
    self.bottomView.count = _arrselected.count;
    
    self.bottomView.isOriginal = _imagePickerVC.isOriginal;
    
}

#pragma mark - 底部栏代理
- (void)bottomViewDidClickOriginalPicture:(UIButton *)originalPictureBtn {

    _imagePickerVC.isOriginal = originalPictureBtn.selected;
}

- (void)bottomViewDidSelectImageWithAssetModel:(DMAssetModel *)assetModel {

    for (int i = 0; i < self.arrAssetModel.count; i++) {
        
        if (self.arrAssetModel[i] == assetModel) {
            
            self.selectedIndex = i;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        }
    }
}

#pragma mark - 导航栏返回按钮
- (void)didClickBackButton {
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 导航栏右侧选中按钮
- (void)didClickSelectedButton:(UIButton *)button {
    
    if (![self checkAssetRequestFinish]) return;
    
    if (_arrselected.count >= _imagePickerVC.maxImagesCount && !_currentAssetModel.selected) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)_imagePickerVC.maxImagesCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:action];
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    button.selected = !button.selected;
    
    if (button.selected) {
        
        //加入到已选数组
        [_imagePickerVC addAssetModel:_currentAssetModel updateArr:_arrselected];
        
        
        [_btnSelected setTitle:[NSString stringWithFormat:@"%ld",_currentAssetModel.index] forState:UIControlStateSelected];
        
        [button.layer addAnimation:[UIView animationForSelectPhoto] forKey:nil];
        
        if (_imagePickerVC.allowInnerPreview) {
            
            //内部预览图插入新的照片
            [self.bottomView insertImage];
            self.bottomView.arrData = _arrselected;
        }
        
    } else {
        
        //从已选数组中删除
        int index = (int)_currentAssetModel.index-1;
        
        [_imagePickerVC removeAssetModel:_currentAssetModel FromDataSource:self.arrAssetModel updateArr:_arrselected];
        
        if (_imagePickerVC.allowInnerPreview) {
            
            //内部预览图删除照片
            [self.bottomView deleteImageOfIndex:index];
            self.bottomView.arrData = _arrselected;
        }
    }
    
    [self refreshBottomView];
    
}

#pragma mark - 滑动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    self.selectedIndex = self.collectionView.contentOffset.x/(KScreen_Width+margin);
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //0 395 790 1185
    //NSLog(@"%f", scrollView.contentOffset.x);
    
    _currentIndex = (self.collectionView.contentOffset.x-margin*self.selectedIndex+KScreen_Width*0.5)/KScreen_Width;

    if (_currentIndex > self.arrAssetModel.count-1 || _currentIndex < 0)
        return;
    
    _currentAssetModel = self.arrAssetModel[_currentIndex];
    
    _btnSelected.selected = _currentAssetModel.selected;
    
    [_btnSelected setTitle:[NSString stringWithFormat:@"%ld",_currentAssetModel.index] forState:UIControlStateSelected];
    
    //如果是视频，隐藏编辑和原图按钮
    _bottomView.isVideo = _currentAssetModel.type == DMAssetModelTypeVideo?YES:NO;
    
    //根据滑动与内部预览View进行照片位置联动
    if (_imagePickerVC.allowInnerPreview) {
        
        BOOL isFind = NO;
        
        for (int i = 0; i < self.bottomView.arrData.count; i++) {
            
            DMAssetModel *assetModel = self.bottomView.arrData[i];
            
            if ([assetModel.asset.localIdentifier isEqualToString:_currentAssetModel.asset.localIdentifier]) {
                
                [self.bottomView scrollToItemOfIndex:i];
                
                isFind = YES;
            }
        }
        
        if (!isFind) {
            self.bottomView.selectedAssetModel.clicked = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectStatusChanged" object:nil];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _currentPreviewCell = [self.collectionView visibleCells].firstObject;

    //暂停视频
    if ([_currentPreviewCell isKindOfClass:[DMVideoPreviewCell class]]) {
        
        [(DMVideoPreviewCell *)_currentPreviewCell pause];
    }
    
}

#pragma mark 进入/退出全屏
- (void)enterFullScreen {
    
//    [UIView animateWithDuration:0.3 animations:^{
    
        CGRect topFrame = self.navigationView.frame;
        topFrame.origin.y = -64;
        self.navigationView.frame = topFrame;
        
        CGRect bottomFrame = self.bottomView.frame;
        bottomFrame.origin.y = KScreen_Height;
        self.bottomView.frame = bottomFrame;
    
    _isFullScreen = YES;
//    }];
}

- (void)quitFullScreen {
    
//    [UIView animateWithDuration:0.3 animations:^{
    
        CGRect topFrame = self.navigationView.frame;
        topFrame.origin.y = 0;
        self.navigationView.frame = topFrame;
        
        CGRect bottomFrame = self.bottomView.frame;
        bottomFrame.origin.y = KScreen_Height-self.bottomView.dm_height;
        self.bottomView.frame = bottomFrame;
    
    _isFullScreen = NO;
//    }];
}

#pragma mark 发送
- (void)bottomViewDidClickSendButton {
    
    if (_arrselected.count <= 0) {
        
        //当已选照片为空，默认发送当前照片
        [self didClickSelectedButton:_btnSelected];
    }
    
    NSArray *arrSelected = _arrselected;
    
    BOOL isOriginal = _imagePickerVC.isOriginal;
    
    NSMutableArray *arrImage = [NSMutableArray array];
    NSMutableArray *arrInfo = [NSMutableArray array];
    
    for (int i = 0; i < _arrselected.count; i++) {
        
        //因为获取图片是异步，所以预设一个数组，根据回调时候的i进行有序替换
        [arrImage addObject:@"placeholder"];
        [arrInfo addObject:@"placeholder"];
    }
    
    for (int i = 0; i < arrSelected.count; i++) {
        
        DMAssetModel *assetModel = arrSelected[i];
        
        [[DMPhotoManager shareManager] requestTargetImageForAsset:assetModel.asset isOriginal:isOriginal complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
            
            if (isDegraded) return ;
            
            if (!image) {
                //当image在浏览过程中被彻底删除
                image = [[UIImage alloc] init];
            }
            
            [arrImage replaceObjectAtIndex:i withObject:image];
            [arrInfo replaceObjectAtIndex:i withObject:info];
            
            for (id asset in arrImage) {
                if ([asset isKindOfClass:[NSString class]]) return;
            }
            
            [_imagePickerVC didFinishPickingImages:arrImage infos:arrInfo assetModel:arrSelected];
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
            
        }];
    }
    
}

#pragma mark - 3D Touch代理
-(UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    _isFullScreen = !_isFullScreen;
    
    return nil;
}

- (void)dealloc {

    NSLog(@"%s", __func__);
}

#pragma mark - 判断资源是否加载完成
- (BOOL)checkAssetRequestFinish {

    _currentPreviewCell = [self.collectionView visibleCells].firstObject;
    BOOL requestFinished = NO;
    if (_currentAssetModel.type == DMAssetModelTypeImage || _currentAssetModel.type == DMAssetModelTypeGif || _currentAssetModel.type == DMAssetModelTypeLivePhoto) {
        
        requestFinished = _currentPreviewCell.photoPreviewView.requestFinished;
    } else if (_currentAssetModel.type == DMAssetModelTypeVideo) {
        
        requestFinished = _currentPreviewCell.videoPreviewView.requestFinished;
    }
    
    return requestFinished;
}


@end

