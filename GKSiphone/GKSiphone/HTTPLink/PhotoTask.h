//
//  PhotoTask.h
//  BeautyGirl
//
//  Created by zhangfeng on 12-11-22.
//  Copyright (c) 2012年 zftank. All rights reserved.
//


@interface PhotoTask : NSOperation <NSURLConnectionDelegate>

- (void)isCancelPhotoView:(id)mark;
- (void)isCancelPhotoController:(id)mark;
- (id)initCallback:(id)callback controller:(id)controller withInfo:(id)requestInfo;

@end
