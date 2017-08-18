//
//  DMThumbnailCell.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMThumbnailCell.h"
#import "UIView+layout.h"
#import "DMPhotoManager.h"
#import "DMExpandButton.h"

#define KbtnSelectWH 26 //选择按钮大小
#define KmarginTopRight 0

@interface DMThumbnailCell ()

@property (nonatomic, strong)UIImageView *ivImageView;

@property (nonatomic, strong)UIButton *btnSelect;

@property (nonatomic, strong)UIView *vCover;

@end

@implementation DMThumbnailCell

- (UIImageView *)ivImageView {
    
    if (!_ivImageView) {
        _ivImageView = [[UIImageView alloc] init];
        _ivImageView.contentMode = UIViewContentModeScaleAspectFill;
        _ivImageView.clipsToBounds = YES;
        [self.contentView addSubview:_ivImageView];
    }
    
    return _ivImageView;
}

- (UIButton *)btnSelect {
    
    if (!_btnSelect) {
        _btnSelect = [DMExpandButton buttonWithType:UIButtonTypeCustom];
        [_btnSelect setBackgroundImage:[UIImage imageNamed:@"FriendsSendsPicturesSelectIcon_27x27_"] forState:UIControlStateNormal];
        [_btnSelect setBackgroundImage:[UIImage imageNamed:@"FriendsSendsPicturesNumberIcon"] forState:UIControlStateSelected];
        [_btnSelect addTarget:self action:@selector(didClickSelecteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnSelect];
    }
    
    return _btnSelect;
}

- (UIView *)vCover {

    if (!_vCover) {
        _vCover = [[UIView alloc] init];
        _vCover.backgroundColor = [UIColor whiteColor];
        _vCover.alpha = 0.8;
        _vCover.userInteractionEnabled = NO;
        [self.contentView addSubview:_vCover];
    }
    
    return _vCover;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.ivImageView.frame = CGRectMake(0, 0, self.contentView.dm_width-1, self.contentView.dm_height);
        
        self.btnSelect.frame = CGRectMake(self.contentView.dm_width-KbtnSelectWH-KmarginTopRight-1, KmarginTopRight, KbtnSelectWH, KbtnSelectWH);
        
        self.vCover.frame = self.bounds;
        self.vCover.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCover:) name:@"NotificationShowCover" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectionIndex) name:@"NotificationSelectionIndexChanged" object:nil];
    }
    
    return self;
}

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    [[DMPhotoManager shareManager] requestImageForAsset:self.assetModel.asset targetSize:CGSizeMake(self.contentView.dm_width, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.ivImageView.image = image;
        
        self.btnSelect.selected = _assetModel.selected;
        [self.btnSelect setTitle:[NSString stringWithFormat:@"%ld", self.assetModel.index] forState:UIControlStateSelected];
        
    }];
    
    if (self.assetModel.userInteractionEnabled) {
        self.vCover.hidden = YES;
    } else {
    
        self.vCover.hidden = NO;
    }
}

#pragma mark 点击选择图片按钮
- (void)didClickSelecteButton:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(thumbnailCell:DidClickSelecteButtonWithAsset:)]) {
        
        [self.delegate thumbnailCell:self DidClickSelecteButtonWithAsset:self.assetModel];
    }
    
    if (self.assetModel.selected) {
        btn.selected = YES;
        [btn.layer addAnimation:[UIView animationForSelectPhoto] forKey:nil];
        
    } else {
        
        btn.selected = NO;
    }
    
}

//更新已选择的索引
- (void)updateSelectionIndex {
    
    [self.btnSelect setTitle:[NSString stringWithFormat:@"%ld", (long)self.assetModel.index] forState:UIControlStateSelected];
}

- (void)showCover:(NSNotification *)notification {

    if ([notification.userInfo[@"remove"] isEqualToString:@"remove"]) {
        self.assetModel.userInteractionEnabled = YES;
        if (!self.vCover) return;
        self.vCover.hidden = YES;
        
    } else {
    
        if (self.assetModel.selected) {
            self.assetModel.userInteractionEnabled = YES;
            self.vCover.hidden = YES;
            
        } else {
            self.assetModel.userInteractionEnabled = NO;
            self.vCover.hidden = NO;
            
        }
    }
}


@end
