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

- (void)layoutSubviews {
    
    self.ivImageView.frame = CGRectMake(0, 0, self.contentView.dm_width, self.contentView.dm_height);
    
    
    self.btnSelect.frame = CGRectMake(self.contentView.dm_width-KbtnSelectWH-KmarginTopRight, KmarginTopRight, KbtnSelectWH, KbtnSelectWH);
}

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    [[DMPhotoManager shareManager] requestImageForAsset:self.assetModel.asset targetSize:CGSizeMake(self.contentView.dm_width, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.ivImageView.image = image;
        
        self.btnSelect.selected = _assetModel.selected;
        [self.btnSelect setTitle:[NSString stringWithFormat:@"%ld", self.assetModel.index] forState:UIControlStateSelected];
        
    }];
}

#pragma mark 点击选择图片按钮
- (void)didClickSelecteButton:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        [btn.layer addAnimation:[UIView animationForSelectPhoto] forKey:nil];
        
        self.assetModel.selected = YES;
    } else {
        
        self.assetModel.selected = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(thumbnailCell:DidClickSelecteButtonWithAsset:)]) {
        
        [self.delegate thumbnailCell:self DidClickSelecteButtonWithAsset:self.assetModel];
    }
}

- (void)updateSelectedIndex:(NSInteger)index {
    
    [self.btnSelect setTitle:[NSString stringWithFormat:@"%ld", (long)index] forState:UIControlStateSelected];
}

@end
