//
//  UIButton+Photo.h
//  Journey
//
//  Created by zhangfeng on 14-3-4.
//  Copyright (c) 2014年 Journey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPDetails.h"

@interface UIButton (Photo)

- (void)cancelPhotoView;

- (BOOL)requestPicture:(id)controller withInfo:(HTTPDetails *)requestInfo;

@end
