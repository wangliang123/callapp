//
//  UIImage+SourceColor.m
//  GJDD
//
//  Created by zftank on 14-9-11.
//  Copyright (c) 2014年 zftank. All rights reserved.
//

#import "UIImage+SourceColor.h"

@implementation UIImage (SourceColor)

+ (UIImage *)imageFromColor:(UIColor *)customColor {
    
    CGSize imageSize = CGSizeMake(1,1);
    
    UIGraphicsBeginImageContextWithOptions(imageSize,0,[UIScreen mainScreen].scale);
    
    [customColor set];
    
    UIRectFill(CGRectMake(0,0,imageSize.width,imageSize.height));
    
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return currentImage;
}

@end
