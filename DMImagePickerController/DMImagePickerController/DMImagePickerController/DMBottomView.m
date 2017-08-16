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

#define btnSendHeight 30
#define btnSendWidth 62
#define marginLR 12
#define btnOriginalWidth 52 //原图按钮宽度
#define btnOriginalHeight 22 //原图按钮高度
#define btnOriginalCycleWidth 20 //原图按钮圆圈的宽度

@interface DMBottomView (){
    
    
}

@property (nonatomic, strong)UIImageView *bgImageView;

//预览
@property (nonatomic, strong)UIButton *btnPreview;

//编辑
@property (nonatomic, strong)UIButton *btnEdit;

//发送
@property (nonatomic, strong)UIButton *btnSend;

//原图
@property (nonatomic, strong)UIButton *btnOriginalPicture;

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
        //        _btnSend.enabled = NO;
        //        _btnPreview.enabled = NO;
        
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

#pragma mark 点击原图按钮
- (void)didSelectedOriginalPictureButton:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(DMBottomViewDidClickedOriginalPicture:)]) {
        
        [self.delegate DMBottomViewDidClickedOriginalPicture:btn];
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

- (void)setSelectedOriginalPicture:(BOOL)selectedOriginalPicture {
    
    _selectedOriginalPicture = selectedOriginalPicture;
    
    _btnOriginalPicture.selected = _selectedOriginalPicture;
}

- (void)setShowEditButton:(BOOL)showEditButton {
    
    _showEditButton = showEditButton;
    
    if (!_showEditButton) return;
    
    self.btnEdit.hidden = NO;
    self.btnPreview.hidden = YES;
}

@end
