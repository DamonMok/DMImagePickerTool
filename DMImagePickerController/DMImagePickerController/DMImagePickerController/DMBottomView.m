//
//  DMBottomView.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMBottomView.h"
#import "UIView+layout.h"
#import "UIButton+category.h"
#import "UIImage+category.h"
#import "UIColor+category.h"
#import "DMDefine.h"
#import "DMPhotoManager.h"

@class DMInnerPreviewCell;

#define btnSendHeight 30
#define btnSendWidth 62
#define marginLR 12
#define btnOriginalWidth 52 //原图按钮宽度
#define btnOriginalHeight 22 //原图按钮高度
#define btnOriginalCycleWidth 20 //原图按钮圆圈的宽度

@interface DMBottomView ()<UICollectionViewDelegate, UICollectionViewDataSource> {

    int _dataCount;//判断是否添加照片

}

@property (nonatomic, strong)UIImageView *bgImageView;//工具条背景

//预览
@property (nonatomic, strong)UIButton *btnPreview;

//编辑
@property (nonatomic, strong)UIButton *btnEdit;

//发送
@property (nonatomic, strong)UIButton *btnSend;

//原图
@property (nonatomic, strong)UIButton *btnOriginalPicture;

//预览View
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)UIImageView *bgInnerView;//内部预览背景

@end

@implementation DMBottomView

- (UIImageView *)bgImageView {
    
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumPhotoImageViewBottomBK"]];
        _bgImageView.alpha = 0.95;
        [self addSubview:_bgImageView];
    }
    
    return _bgImageView;
}

- (UIButton *)btnPreview {
    
    if (!_btnPreview) {
        _btnPreview = [UIButton buttonWithLeftMargin:0 topMargin:0];
        [_btnPreview setTitle:@"预览" forState:UIControlStateNormal];
        [_btnPreview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnPreview setTitleColor:[UIColor colorWithRed:104/255.0 green:108/255.0 blue:112/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [_btnPreview setTitleColor:[UIColor colorWithRed:168/255.0 green:171/255.0 blue:173/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        _btnPreview.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_btnPreview addTarget:self action:@selector(didClickPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnPreview];
    }
    
    return _btnPreview;
}

- (UIButton *)btnEdit {
    
    if (!_btnEdit) {
        _btnEdit = [UIButton buttonWithLeftMargin:0 topMargin:0];
        [_btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        [_btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnEdit setTitleColor:[UIColor colorWithRed:104/255.0 green:108/255.0 blue:112/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [_btnEdit setTitleColor:[UIColor colorWithRed:168/255.0 green:171/255.0 blue:173/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        _btnEdit.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_btnEdit];
    }
    
    return _btnEdit;
}

- (UIButton *)btnSend {
    
    if (!_btnSend) {
        _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSend setTitle:@"发送" forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor colorWithRed:93/255.0 green:134/255.0 blue:92/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [_btnSend setTitleColor:[UIColor colorWithRed:163/255.0 green:222/255.0 blue:163/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [_btnSend setBackgroundImage:[UIImage imageWithColor:HEXColor(@"1aad19")] forState:UIControlStateNormal];
        [_btnSend setBackgroundImage:[UIImage imageWithColor:HEXColor(@"175216")] forState:UIControlStateDisabled];
        [_btnSend setBackgroundImage:[UIImage imageWithColor:HEXColor(@"1aad19")] forState:UIControlStateHighlighted];
        _btnSend.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _btnSend.layer.cornerRadius = 5;
        _btnSend.layer.masksToBounds = YES;
        [_btnSend addTarget:self action:@selector(didClickSendButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_btnSend];
    }
    
    return _btnSend;
}

- (UIButton *)btnOriginalPicture {
    
    if (!_btnOriginalPicture) {
        _btnOriginalPicture = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_btnOriginalPicture setImage:[UIImage imageNamed:@"FriendsSendsPicturesArtworkNIcon"] forState:UIControlStateNormal];
        [_btnOriginalPicture setImage:[UIImage imageNamed:@"FriendsSendsPicturesArtworkIcon"] forState:UIControlStateSelected];
        [_btnOriginalPicture setTitle:@"原图" forState:UIControlStateNormal];
        _btnOriginalPicture.titleLabel.font = [UIFont systemFontOfSize:12.0];
        CGSize size = [_btnOriginalPicture.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        _btnOriginalPicture.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, btnOriginalWidth-btnOriginalCycleWidth);
        _btnOriginalPicture.titleEdgeInsets = UIEdgeInsetsMake(0, btnOriginalWidth-btnOriginalCycleWidth-size.width-5, 0, 0);
        [_btnOriginalPicture addTarget:self action:@selector(didSelectedOriginalPictureButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_btnOriginalPicture];
    }
    
    return _btnOriginalPicture;
}

- (UICollectionView *)collectionView {

    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 12;
        flowLayout.itemSize = CGSizeMake(64, 64);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.backgroundView = self.bgInnerView;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = YES;
        [_collectionView registerClass:[DMInnerPreviewCell class] forCellWithReuseIdentifier:@"innerPreview"];
    }
    
    return _collectionView;
}

- (UIImageView *)bgInnerView {

    if (!_bgInnerView) {
        _bgInnerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumPhotoImageViewBottomBK"]];
        _bgInnerView.alpha = 0.95;
    }
    
    return _bgInnerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initViewsWithFrame:frame];
    }
    
    return self;
}

- (void)initViewsWithFrame:(CGRect)frame {
    
    self.bgImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    self.btnPreview.frame = CGRectMake(marginLR, 0, self.btnPreview.width, self.btnPreview.height);
    self.btnPreview.dm_centerY = frame.size.height/2;
    
    self.btnEdit.frame = CGRectMake(marginLR, 0, self.btnEdit.width, self.btnEdit.height);
    self.btnEdit.dm_centerY = frame.size.height/2;
    self.btnEdit.hidden = YES;
    
    self.btnSend.frame = CGRectMake(frame.size.width-btnSendWidth-marginLR, 0, btnSendWidth, btnSendHeight);
    self.btnSend.dm_centerY = frame.size.height/2;
    
    self.btnOriginalPicture.frame = CGRectMake(0, 0, btnOriginalWidth, btnOriginalHeight );
    self.btnOriginalPicture.dm_centerY = frame.size.height/2;
    self.btnOriginalPicture.dm_centerX = frame.size.width/2;
}

#pragma mark 点击预览按钮
- (void)didClickPreviewButton:(UIButton *)btn {

    if ([self.delegate respondsToSelector:@selector(bottomViewDidClickPreviewButton)]) {
        
        [self.delegate bottomViewDidClickPreviewButton];
    }
}

#pragma mark 点击原图按钮
- (void)didSelectedOriginalPictureButton:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(bottomViewDidClickOriginalPicture:)]) {
        
        [self.delegate bottomViewDidClickOriginalPicture:btn];
    }
}

#pragma mark 点击发送按钮
- (void)didClickSendButton {

    if ([self.delegate respondsToSelector:@selector(bottomViewDidClickSendButton)]) {
        [self.delegate bottomViewDidClickSendButton];
    }
}

- (void)setCount:(NSInteger)count {
    
    _count = count;
    
    if (count <= 0 && !self.sendEnable) {
        _btnPreview.enabled = NO;
        _btnSend.enabled = NO;
        [_btnSend setTitle:@"发送" forState:UIControlStateNormal];
    } else {
        _btnPreview.enabled = YES;
        _btnSend.enabled = YES;
        
        if (count <= 0) {
            [_btnSend setTitle:@"发送" forState:UIControlStateNormal];
            return;
        }
        
        [_btnSend setTitle:[NSString stringWithFormat:@"发送(%ld)",(long)count] forState:UIControlStateNormal];
    }
}

- (void)setIsOriginal:(BOOL)isOriginal {
    
    _isOriginal = isOriginal;
    
    _btnOriginalPicture.selected = _isOriginal;
}

- (void)setShowEditButton:(BOOL)showEditButton {
    
    _showEditButton = showEditButton;
    
    if (!_showEditButton) return;
    
    self.btnEdit.hidden = NO;
    self.btnPreview.hidden = YES;
}

- (void)setIsVideo:(BOOL)isVideo {

    _isVideo = isVideo;
    
    if (isVideo) {
        _btnEdit.hidden = YES;
        _btnOriginalPicture.hidden = YES;
    } else {
        _btnEdit.hidden = NO;
        _btnOriginalPicture.hidden = NO;
    }
}

- (void)setShowInnerPreview:(BOOL)showInnerPreview {

    _showInnerPreview = showInnerPreview;
    
    if (!_showInnerPreview) return;
    
    self.collectionView.frame = CGRectMake(0, 0, KScreen_Width, KInnerPreviewHeight);
    [self addSubview:self.collectionView];
    
    self.btnEdit.dm_y += KInnerPreviewHeight;
    self.btnSend.dm_y += KInnerPreviewHeight;
    self.btnOriginalPicture.dm_y += KInnerPreviewHeight;
    self.btnPreview.dm_y += KInnerPreviewHeight;
    self.bgImageView.dm_y += KInnerPreviewHeight;
    
}

- (void)setArrData:(NSArray *)arrData {

    _arrData = arrData;
    
    if (!_showInnerPreview) return;
    
    if (_arrData.count > 0) {
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.collectionView.alpha = 1;
        }];
        
    } else {
    
        [UIView animateWithDuration:0.25 animations:^{
            
            self.collectionView.alpha = 0;
        }];
    }
    
    BOOL userInteractionEnabled = _arrData.count;
    self.collectionView.userInteractionEnabled = userInteractionEnabled;
    self.userInteractionEnabled = userInteractionEnabled;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    DMInnerPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"innerPreview" forIndexPath:indexPath];
    
    cell.assetModel = self.arrData[indexPath.row];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    //点击切换选中边框
    _selectedAssetModel.clicked = NO;
    DMAssetModel *assetModel = self.arrData[indexPath.row];
    assetModel.clicked = YES;
    _selectedAssetModel = assetModel;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectStatusChanged" object:nil];
    
    if (_arrData.count <= 0) return;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(bottomViewDidSelectImageWithAssetModel:)]) {
        
        [self.delegate bottomViewDidSelectImageWithAssetModel:self.arrData[indexPath.row]];
    }
}

- (void)scrollToItemOfIndex:(int)index {
    
    if (!self.showInnerPreview) return;
    
    if (index < 0) return;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    _selectedAssetModel.clicked = NO;
    DMAssetModel *assetModel = self.arrData[index];
    assetModel.clicked = YES;
    _selectedAssetModel = assetModel;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectStatusChanged" object:nil];
    
}

#pragma mark - 增删预览图
- (void)insertImage {

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_arrData.count-1 inSection:0];
    
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    
    if (_arrData.count>_dataCount) {
        //添加新照片,滚动到新添加图片的位置
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_arrData.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

        //设置选择框
        _selectedAssetModel.clicked = NO;
        DMAssetModel *assetModel = self.arrData.lastObject;
        assetModel.clicked = YES;
        _selectedAssetModel = assetModel;

        //发送通知改变边框
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectStatusChanged" object:nil];
    }
}

- (void)deleteImageOfIndex:(int)index {

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if (CGRectContainsPoint(_btnSend.frame, point)) {
        
        return _btnSend;
    } else if (CGRectContainsPoint(_btnEdit.frame, point)) {
    
        return _btnEdit;
    } else if (CGRectContainsPoint(_btnOriginalPicture.frame, point)) {
    
        return _btnOriginalPicture;
    } else if (CGRectContainsPoint(_btnPreview.frame, point)) {
    
        return _btnPreview;
    }
    
    return [super hitTest:point withEvent:event];
}


@end


@interface DMInnerPreviewCell ()

@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation DMInnerPreviewCell

- (UIImageView *)imageView {

    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 81/255.0, 170/255.0, 55/255.0, 1 });
        [_imageView.layer setBorderColor:colorref];//边框颜色
        CGColorRelease(colorref);
        CGColorSpaceRelease(colorSpace);
    }
    
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.imageView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.imageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectStatusChanged) name:@"selectStatusChanged" object:nil];
    }
    
    return self;
}

- (void)setAssetModel:(DMAssetModel *)assetModel {

    _assetModel = assetModel;
    
    [[DMPhotoManager shareManager] requestImageForAsset:self.assetModel.asset targetSize:CGSizeMake(60, 60) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        if (image) {
            self.imageView.image = image;
        }
    } progressHandler:nil];
    
    if (self.assetModel.clicked) {
        //有边框
        [self.imageView.layer setBorderWidth:2.0];
    } else {
        //无边框
        [self.imageView.layer setBorderWidth:0];
        
    }
    
}

- (void)selectStatusChanged {

    if (self.assetModel.clicked) {
        //有边框
        [self.imageView.layer setBorderWidth:2.0];   //边框宽度
        
    } else {
        //无边框
        [self.imageView.layer setBorderWidth:0];

    }
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectStatusChanged" object:nil];
    self.assetModel.clicked = NO;
}


@end
