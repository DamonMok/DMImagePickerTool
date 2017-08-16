//
//  UIButton+category.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//


#import "UIButton+category.h"

@implementation UIButton (category)

- (CGFloat)width {
    
    NSString *titleLabelText = self.titleLabel.text;
    
    CGSize size = [titleLabelText sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.titleLabel.font.fontName size:self.titleLabel.font.pointSize], NSKernAttributeName:@1.0f}];
    
    return size.width+2*self.contentEdgeInsets.left;
}

- (void)setWidth:(CGFloat)width {
    
    self.width = width;
}

- (CGFloat)height {
    
    NSString *titleLabelText = self.titleLabel.text;
    
    CGSize size = [titleLabelText sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.titleLabel.font.fontName size:self.titleLabel.font.pointSize], NSKernAttributeName:@1.0f}];
    
    return size.height+2*self.contentEdgeInsets.top;
}

- (void)setHeight:(CGFloat)height {
    
    self.height = height;
}

+ (instancetype)buttonWithLeftMargin:(CGFloat)leftMargin topMargin:(CGFloat)topMargin {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.contentEdgeInsets = UIEdgeInsetsMake(topMargin, leftMargin, topMargin, leftMargin);
    
    return btn;
}

@end

