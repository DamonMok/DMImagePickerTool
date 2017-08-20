//
//  DMAlbumCell.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMAlbumCell.h"
#import "DMPhotoManager.h"
#import "UIView+layout.h"
#import "DMDefine.h"

@interface DMAlbumCell ()

//封面
@property (nonatomic, strong)UIImageView *ivCoverImage;

//标题
@property (nonatomic, strong)UILabel *labTitle;

@property (nonatomic, strong)UIImageView *ivArrow;

@end

@implementation DMAlbumCell

- (UIImageView *)ivCoverImage {
    
    if (!_ivCoverImage) {
        
        _ivCoverImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav_list_img_default"]];
        _ivCoverImage.contentMode = UIViewContentModeScaleAspectFill;
        _ivCoverImage.clipsToBounds = YES;
        [self.contentView addSubview:self.ivCoverImage];
    }
    
    return _ivCoverImage;
}

- (UILabel *)labTitle {
    
    if (!_labTitle) {
        _labTitle = [[UILabel alloc] init];
        [self.contentView addSubview:self.labTitle];
    }
    
    return _labTitle;
}

- (UIImageView *)ivArrow {
    
    if (!_ivArrow) {
        _ivArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_ico"]];
        [self.contentView addSubview:_ivArrow];
    }
    
    return _ivArrow;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    
    self.ivCoverImage.frame = CGRectMake(0, 0, KAlbumViewRowHeight, KAlbumViewRowHeight);
    
    self.labTitle.frame = CGRectMake(66, 0, 200, 16);
    self.labTitle.dm_centerY = KAlbumViewRowHeight/2;
    
    self.ivArrow.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-6-20, 0, 6, 12);
    self.ivArrow.dm_centerY = KAlbumViewRowHeight/2;
    
}

- (void)setAlbumModel:(DMAlbumModel *)albumModel {
    
    _albumModel = albumModel;
    
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:self.albumModel.albumTitle attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0], NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSMutableAttributedString *countAttribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   (%ld)", (long)self.albumModel.count] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0], NSForegroundColorAttributeName:[UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1]}];
    [titleAttribute appendAttributedString:countAttribute];
    self.labTitle.attributedText = titleAttribute;
    
    [[DMPhotoManager shareManager] requestPosterImageWithAlbumModel:albumModel complete:^(UIImage *image, NSDictionary *info) {
        
        if (image) {
            self.ivCoverImage.image = image;
            _ivCoverImage.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            self.ivCoverImage.image = [UIImage imageNamed:@"fav_list_img_default"];
            _ivCoverImage.contentMode = UIViewContentModeScaleAspectFit;
        }
    }];
}


@end
