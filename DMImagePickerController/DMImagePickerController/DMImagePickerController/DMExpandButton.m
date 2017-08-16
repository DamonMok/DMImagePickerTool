//
//  DMExpandButton.m
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMExpandButton.h"

@implementation DMExpandButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect rect = self.bounds;
    
    rect = CGRectInset(rect, -rect.size.width*0.7, -rect.size.height*0.7);
    
    
    return CGRectContainsPoint(rect, point);
}

@end
