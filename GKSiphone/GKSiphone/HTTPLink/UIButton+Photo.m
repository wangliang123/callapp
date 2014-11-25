//
//  UIButton+Photo.m
//  Journey
//
//  Created by zhangfeng on 14-3-4.
//  Copyright (c) 2014年 Journey. All rights reserved.
//

#import "UIButton+Photo.h"
#import <objc/runtime.h>
#import "HTTPConnection.h"

static char buttonKey;

@implementation UIButton (Photo)

- (void)cancelPhotoView {
    
    [HTTPLink cancelPhotoView:self];
}

- (BOOL)requestPicture:(id)controller withInfo:(HTTPDetails *)requestInfo {
    
    BOOL havePicture = NO;
    
    objc_setAssociatedObject(self,&buttonKey,requestInfo.requestHost,OBJC_ASSOCIATION_ASSIGN);
    
    if (requestInfo.requestHost)
    {
        if (requestInfo.cachePhoto == nil)
        {
            requestInfo.cachePhoto = [FileOperation makePhotoCachePath:requestInfo.requestHost];
        }
        
        UIImage *theImage = [UIImage imageWithContentsOfFile:requestInfo.cachePhoto];
        
        if (theImage)
        {
            havePicture = YES;
            
            [self loadPicture:theImage surface:requestInfo.surfaceOfButton];
        }
        else
        {
            [self cancelPhotoView];
            
            [self loadPicture:requestInfo.defaultPhoto surface:YES];
            
            [HTTPLink requestPhoto:self controller:controller withInfo:requestInfo];
        }
    }
    else
    {
        [self loadPicture:requestInfo.defaultPhoto surface:YES];
    }
    
    return havePicture;
}

- (void)loadPicture:(UIImage *)theImage surface:(BOOL)surface {
    
    if (surface)
    {
        [self setImage:theImage forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateNormal];
    }
    else
    {
        [self setImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:theImage forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark RequestDelegate Methods

- (void)requestSucces:(HTTPDetails *)data {
    
    id beforeUrl = objc_getAssociatedObject(self,&buttonKey);
    
    if ([data.requestHost isEqual:beforeUrl])
    {
        [self loadPicture:data.responseData surface:data.surfaceOfButton];
    }
}

- (void)requestWrong:(HTTPDetails *)data {
    
    id beforeUrl = objc_getAssociatedObject(self,&buttonKey);
    
    if ([data.requestHost isEqual:beforeUrl])
    {
        
    }
}

@end
