//
//  UIButton+category.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (category)

@property (nonatomic, assign)CGFloat width;

@property (nonatomic, assign)CGFloat height;

/**
 创建一个根据文字长度自适应宽高的button
 @param leftMargin 左右内边距
 @param topMargin 上下内边距
 @return 根据文字自适应宽高的button
 */
+ (instancetype)buttonWithLeftMargin:(CGFloat)leftMargin topMargin:(CGFloat)topMargin;

@end
