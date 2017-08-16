//
//  UIView+layout.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "UIView+layout.h"

@implementation UIView (layout)

- (CGFloat)dm_x {
    
    return self.frame.origin.x;
}

- (void)setDm_x:(CGFloat)dm_x {
    
    CGRect frame = self.frame;
    frame.origin.x = dm_x;
    self.frame = frame;
}

- (CGFloat)dm_y {
    
    return self.frame.origin.y;
}

- (void)setDm_y:(CGFloat)dm_y {
    
    CGRect frame = self.frame;
    frame.origin.y = dm_y;
    self.frame = frame;
}

- (CGFloat)dm_width {
    
    return self.frame.size.width;
}

- (void)setDm_width:(CGFloat)dm_width {
    
    CGRect frame = self.frame;
    frame.size.width = dm_width;
    self.frame = frame;
}

- (CGFloat)dm_height {
    
    return self.frame.size.height;
}

- (void)setDm_height:(CGFloat)dm_height {
    
    CGRect frame = self.frame;
    frame.size.height = dm_height;
    self.frame = frame;
}

- (CGFloat)dm_centerY {
    
    return self.center.y;
}

- (void)setDm_centerY:(CGFloat)dm_centerY {
    
    CGPoint center = self.center;
    center.y = dm_centerY;
    self.center = center;
}

- (CGFloat)dm_centerX {
    
    return self.center.x;
}

- (void)setDm_centerX:(CGFloat)dm_centerX {
    
    CGPoint center = self.center;
    center.x = dm_centerX;
    self.center = center;
}

+ (CAKeyframeAnimation *)animationForSelectPhoto {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    
    animation.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]
                         ];
    
    return animation;
}

@end

