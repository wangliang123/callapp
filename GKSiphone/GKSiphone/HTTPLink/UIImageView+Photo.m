//
//  UIImageView+Photo.m
//  Journey
//
//  Created by zhangfeng on 14-3-4.
//  Copyright (c) 2014年 Journey. All rights reserved.
//

#import "UIImageView+Photo.h"
#import <objc/runtime.h>
#import "HTTPConnection.h"

static char imageViewKey;

@implementation UIImageView (Photo)

- (void)cancelPhotoView {
    
    [HTTPLink cancelPhotoView:self];
}

- (BOOL)requestPicture:(id)controller withInfo:(HTTPDetails *)requestInfo {
    
    BOOL havePicture = NO;
    
    objc_setAssociatedObject(self,&imageViewKey,requestInfo.requestHost,OBJC_ASSOCIATION_ASSIGN);
    
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
            
            self.image = theImage;
        }
        else
        {
            [self cancelPhotoView];
            
            self.image = requestInfo.defaultPhoto;
            
            [HTTPLink requestPhoto:self controller:controller withInfo:requestInfo];
        }
    }
    else
    {
        self.image = requestInfo.defaultPhoto;
    }
    
    return havePicture;
}

#pragma mark -
#pragma mark RequestDelegate Methods

- (void)requestSucces:(HTTPDetails *)data {
    
    id beforeUrl = objc_getAssociatedObject(self,&imageViewKey);
    
    if ([data.requestHost isEqual:beforeUrl])
    {
        self.image = data.responseData;
    }
}

- (void)requestWrong:(HTTPDetails *)data {
    
    id beforeUrl = objc_getAssociatedObject(self,&imageViewKey);
    
    if ([data.requestHost isEqual:beforeUrl])
    {
        
    }
}

@end
