//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface SVProgressHUD : NSObject

+ (void)dismiss;//消除所有弹框

+ (void)showMessage:(NSString *)title duration:(NSTimeInterval)duration;//在底部展现提示语

+ (void)showLoading;

@end
