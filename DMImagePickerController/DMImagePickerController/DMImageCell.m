//
//  DMImageCell.m
//  DMImagePickerController
//
//  Created by Damon on 2017/9/28.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMImageCell.h"

@interface DMImageCell ()

@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation DMImageCell

- (UIImageView *)imageView {

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
        
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _imageView.layer.masksToBounds = YES;
    }
    
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self initView];
    }
    
    return self;
}

- (void)initView {

    self.imageView.frame = self.contentView.bounds;
    
    [self.contentView addSubview:self.imageView];
}

- (void)setImage:(UIImage *)image {

    _image = image;
    
    self.imageView.image = _image;
}

@end
