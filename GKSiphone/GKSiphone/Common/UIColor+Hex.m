//
//  UIColor+Hex.m
//  BaiduGirl
//
//  Created by shituanwei@baidu.com on 11-8-1.
//  Copyright 2012 Baidu. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(uint)hex {
    
    int red, green, blue, alpha;
    
    blue = hex & 0x000000FF;
    green = ((hex & 0x0000FF00) >> 8);
    red = ((hex & 0x00FF0000) >> 16);
    alpha = ((hex & 0xFF000000) >> 24);
    
    return [UIColor colorWithRed:red/255.0f 
                           green:green/255.0f 
                            blue:blue/255.0f 
                           alpha:alpha/255.f];
}

+ (UIColor *)colorWithRGB:(uint)rgbValue {
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
