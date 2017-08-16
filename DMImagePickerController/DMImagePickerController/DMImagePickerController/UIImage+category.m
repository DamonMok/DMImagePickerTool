//
//  UIImage+category.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#define MAX_IMAGE_PIX 1000.0  //图片宽高:1000像素以内
#define MAX_IMAGE_DATA_LENGTH 204800.0 //图片数据长度:200K以内

#import "UIImage+category.h"

@implementation UIImage (Extension)

#pragma mark - 根据颜色生成图片
+ (UIImage *) imageWithColor:(UIColor *)color {
    
    return [self imageWithColor:color imageSize:CGSizeMake(1.0f, 1.0f)];
    
}

+ (UIImage *)imageWithColor:(UIColor *)color imageSize:(CGSize)size {
    
    CGRect rect=CGRectMake(0.0f,0.0f,size.width,size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage*theImage=UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();
    
    return theImage;
}

#pragma mark - 图片压缩
- (UIImage *)compressImage {
    
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    if (width <= MAX_IMAGE_PIX && height <= MAX_IMAGE_PIX)
        return self;
    
    if (width == 0 || height == 0)
        return self;
    
    UIImage *targetImage = nil;
    
    CGFloat widthRatio = MAX_IMAGE_PIX/width;
    CGFloat heightRatio = MAX_IMAGE_PIX/height;
    CGFloat scale = 0;
    
    scale = widthRatio > heightRatio?heightRatio:widthRatio;
    
    CGSize targetSize = CGSizeMake(width*scale, height*scale);
    
    UIGraphicsBeginImageContext(targetSize);
    
    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    targetImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return targetImage;
}

- (NSData *)compressImageByQuality {
    
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    
    if (data.length <= MAX_IMAGE_DATA_LENGTH)
        return data;
    
    CGFloat scale = MAX_IMAGE_DATA_LENGTH/data.length;
    
    NSData *targetData = UIImageJPEGRepresentation(self, scale);
    
    return targetData;
}



@end
