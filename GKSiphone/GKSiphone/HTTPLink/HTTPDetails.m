//
//  HTTPDetails.m
//  JiuTianWaiApp
//
//  Created by zhangfeng on 13-6-21.
//  Copyright (c) 2013年 MasterPlate. All rights reserved.
//

#import "HTTPDetails.h"

@implementation PostInfomation

- (id)init {

    self = [super init];
    
    if (self)
    {
        self.dataKey = nil;
        
        self.dataSource = nil;
    }
    
    return self;
}

@end

@implementation HTTPDetails

- (id)init {

    self = [super init];
    
    if (self)
    {
        self.requestHost = nil;
        self.requestInterface = nil;
        self.requestMethod = kPostMethod;
        
        self.addHeader = nil;
        self.extensionInfo = nil;
        
        self.requestBody = nil;
        self.customBody = nil;
        
        self.responseHeader = nil;
        self.responseData = nil;
        
        self.requestError = 0;
        self.brokenNetwork = YES;
        
        self.defaultPhoto = nil;
        self.cachePhoto = nil;
        self.surfaceOfButton = YES;
        
        self.listItem = nil;
    }
    
    return self;
}

@end
