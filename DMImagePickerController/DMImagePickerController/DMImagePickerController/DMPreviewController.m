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

static NSString *reusedID = @"preview";

@interface DMPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource, DMBottomViewDelegate>{
    
    DMImagePickerController *_imagePickerVC;
    
    UIButton *_btnSelected;
    
    int _currentIndex;//当前索引
    int _currentPage;//当前页数
    
    DMAssetModel *_currentAssetModel;//当前模型
    
    BOOL _isFullScreen;
    
}

@property (nonatomic, strong)UIView *navigationView;

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)DMBottomView *bottomView;

@end

@implementation DMPreviewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initCollectionView];
    [self initNavigationBar];
    [self initBottomView];
    [self refreshBottomView];
    [self scrollToTargetItem];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
    
    //selectedStatus
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
    [self.collectionView registerClass:[DMPreviewCell class] forCellWithReuseIdentifier:reusedID];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - 初始化底部栏
- (void)initBottomView {
    
    self.bottomView.delegate = self;
    self.bottomView.showEditButton = YES;
    self.bottomView.sendEnable = YES;
    [self.view addSubview:self.bottomView];
}

#pragma mark - 滚动到目标Item
- (void)scrollToTargetItem {
    
    if (self.selectedIndex > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
    } else if (self.selectedIndex == 0) {
        
        //index为0的时候，根据model调整按钮状态
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
    
    DMPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusedID forIndexPath:indexPath];
    
    cell.assetModel = assetModel;
    
    cell.singleTap = ^{
        
        _isFullScreen = !_isFullScreen;
        
        if (_isFullScreen) {
            [self enterFullScreen];
        } else {
            [self quitFullScreen];
        }
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [((DMPreviewCell *)cell).previewView.imagePreviewView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark - 刷新底部栏
- (void)refreshBottomView {
    
    
    _imagePickerVC = (DMImagePickerController *)self.navigationController;
    
    self.bottomView.count = _imagePickerVC.arrselected.count;
    
    self.bottomView.selectedOriginalPicture = _imagePickerVC.selectedOriginalPicture;
    
}

#pragma mark - 底部栏代理
- (void)DMBottomViewDidClickOriginalPicture:(UIButton *)originalPictureBtn {
    
    _imagePickerVC.selectedOriginalPicture = originalPictureBtn.selected;
}

#pragma mark - 导航栏返回按钮
- (void)didClickBackButton {
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 导航栏右侧选中按钮
- (void)didClickSelectedButton:(UIButton *)button {
    
    if (_imagePickerVC.arrselected.count >= _imagePickerVC.maxImagesCount && !_currentAssetModel.selected) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)_imagePickerVC.maxImagesCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:action];
        [self.navigationController presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    button.selected = !button.selected;
    
    if (button.selected) {
        
        //加入到已选数组
        [_imagePickerVC addAssetModel:_currentAssetModel];
        
        [_btnSelected setTitle:[NSString stringWithFormat:@"%ld",_currentAssetModel.index] forState:UIControlStateSelected];
        
        [button.layer addAnimation:[UIView animationForSelectPhoto] forKey:nil];
    } else {
        
        //从已选数组中删除
        [_imagePickerVC removeAssetModel:_currentAssetModel FromDataSource:self.arrAssetModel];
        
    }
    
    [self refreshBottomView];
    
}

#pragma mark - 滑动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    self.selectedIndex = self.collectionView.contentOffset.x/(KScreen_Width+margin);

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //0 395 790 1185
    NSLog(@"%f", scrollView.contentOffset.x);
    
    _currentIndex = (self.collectionView.contentOffset.x-margin*self.selectedIndex+KScreen_Width*0.5)/KScreen_Width;
    
    if (_currentIndex > self.arrAssetModel.count-1 || _currentIndex < 0 )
        return;
    
    _currentAssetModel = self.arrAssetModel[_currentIndex];
    
    _btnSelected.selected = _currentAssetModel.selected;
    
    [_btnSelected setTitle:[NSString stringWithFormat:@"%ld",(long)_currentAssetModel.index] forState:UIControlStateSelected];
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
        
//    }];
}

- (void)quitFullScreen {
    
//    [UIView animateWithDuration:0.3 animations:^{
    
        CGRect topFrame = self.navigationView.frame;
        topFrame.origin.y = 0;
        self.navigationView.frame = topFrame;
        
        CGRect bottomFrame = self.bottomView.frame;
        bottomFrame.origin.y = KScreen_Height-bottomViewHeight;
        self.bottomView.frame = bottomFrame;
        
//    }];
}

@end

