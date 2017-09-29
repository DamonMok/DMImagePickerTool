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

#define KtimelineBgHeight 26    //类型标识背景高
#define Kmargin 8
#define KlabelHeight 16
#define KvideoWidth 16  //视频图标宽
#define kvideoHeight 10 //视频图标高


@interface DMThumbnailCell ()

@property (nonatomic, strong)UIImageView *ivImageView;//照片View

@property (nonatomic, strong)UIButton *btnSelect;//选择按钮

@property (nonatomic, strong)UIView *vCover;//不可交互时的遮盖

@property (nonatomic, strong)UILabel *labType;//照片类型标识

@property (nonatomic, strong)UIImageView *ivTypeBg;//照片类型背景

@end

@implementation DMThumbnailCell

#pragma mark - lazy load
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

- (UILabel *)labType {

    if (!_labType) {
        
        _labType = [[UILabel alloc] init];
        [self.contentView addSubview:_labType];
    }
    
    return _labType;
}

- (UIImageView *)ivTypeBg {

    if (!_ivTypeBg) {
        
        _ivTypeBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Albumtimeline_video_shadow"]];
        [self.contentView addSubview:_ivTypeBg];
    }
    
    return _ivTypeBg;
}

#pragma frame
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.ivImageView.frame = CGRectMake(0, 0, self.contentView.dm_width-1, self.contentView.dm_height);
        
        self.btnSelect.frame = CGRectMake(self.contentView.dm_width-KbtnSelectWH-KmarginTopRight-1, KmarginTopRight, KbtnSelectWH, KbtnSelectWH);
        
        self.vCover.frame = self.bounds;
        self.vCover.hidden = YES;
        
        self.ivTypeBg.frame = CGRectMake(0, frame.size.height-KtimelineBgHeight, frame.size.width, KtimelineBgHeight);
        
        self.labType.frame = CGRectMake(Kmargin, frame.size.height-KlabelHeight-Kmargin+2, frame.size.width-2*Kmargin, KlabelHeight);
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCover:) name:@"NotificationShowCover" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectionIndex) name:@"NotificationSelectionIndexChanged" object:nil];
    }
    
    return self;
}

- (void)setAssetModel:(DMAssetModel *)assetModel {
    
    _assetModel = assetModel;
    
    [self configTypeWithAssetModel:assetModel];
    
    [[DMPhotoManager shareManager] requestImageForAsset:self.assetModel.asset targetSize:CGSizeMake(self.contentView.dm_width, MAXFLOAT) complete:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        
        self.ivImageView.image = image;
        
        if (!isDegraded) {
            
            self.requestFinished = YES;
        }
        
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
        self.requestFinished = NO;
    }];
    
    //选择按钮
    self.btnSelect.selected = _assetModel.selected;
    
    if (self.btnSelect.selected) {
        
        [self.btnSelect setTitle:[NSString stringWithFormat:@"%ld", self.assetModel.index] forState:UIControlStateSelected];
    } else {
    
        [self.btnSelect setTitle:nil forState:UIControlStateNormal];
    }
    
    //遮盖
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

#pragma mark 设置照片类型(Gif/LivePhoto/Video)
- (void)configTypeWithAssetModel:(DMAssetModel *)assetModel {
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] init];

    //图片
    NSTextAttachment *attachImage = [[NSTextAttachment alloc] init];
    
    NSAttributedString *attriImage = [NSAttributedString attributedStringWithAttachment:attachImage];
    
    //文字
    NSAttributedString *attriText;

    //背景
    self.ivTypeBg.hidden = NO;
    
    switch (assetModel.type) {
        case DMAssetModelTypeVideo:
            
            //视频图标
            attachImage.bounds = CGRectMake(1, -1, KvideoWidth, kvideoHeight);
            attachImage.image = [UIImage imageNamed:@"fileicon_video_wall"];
            [attri appendAttributedString:attriImage];
            
            //视频长度
            attriText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", assetModel.durationTime] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
            [attri appendAttributedString:attriText];
            break;
            
        case DMAssetModelTypeGif:
            
            //Gif文字
            attriText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"GIF"] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]}];
            [attri appendAttributedString:attriText];
            break;
            
        case DMAssetModelTypeLivePhoto:
            
            //LivePhoto图标
            attachImage.bounds = CGRectMake(1, -2, 16, 16);
            attachImage.image = [UIImage imageNamed:@"livePhoto"];
            [attri appendAttributedString:attriImage];
            break;
            
        default:
            self.ivTypeBg.hidden = YES;
            break;
    }

    self.labType.attributedText = attri;
    
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationShowCover" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationSelectionIndexChanged" object:nil];
}


@end
