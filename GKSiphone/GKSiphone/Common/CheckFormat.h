//
//  CheckFormat.h
//  MarketWork
//
//  Created by zftank on 14-7-28.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckFormat : NSObject

+ (BOOL)isEmailAddress:(NSString *)email;//判断字符串是否邮箱

+ (BOOL)isMobileNumber:(NSString *)mobileNum;//判断字符串是否手机号码

+ (BOOL)characterString:(NSString *)string;//判断字符串是否只包含汉字、字母

@end
