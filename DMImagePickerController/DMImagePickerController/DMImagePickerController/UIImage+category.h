//
//  UIImage+category.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 *  根据颜色渲染成图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
+ (UIImage *) imageWithColor:(UIColor *)color;

/**
 *  根据颜色渲染成图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
+ (UIImage *) imageWithColor:(UIColor *)color imageSize:(CGSize)size;

/**
 基于像素压缩图片
 @return 压缩像素后的图片
 */
- (UIImage *)compressImage;


/**
 基于质量压缩图片
 @return 压缩质量后的图片
 */
- (NSData *)compressImageByQuality;



@end
