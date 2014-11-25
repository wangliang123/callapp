//
//  CommonBlockTask.m
//  MarketWork
//
//  Created by 陈扬 on 14-5-13.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "CommonBlockTask.h"
#import "HTTPConnection.h"

@interface CommonBlockTask ()

@property (nonatomic,copy) SuccessHanler successHandler;
@property (nonatomic,copy) FailedHanler failedHandler;

@end

@implementation CommonBlockTask

- (id)initCallback:(id)callback withInfo:(HTTPDetails *)info successBlock:(SuccessHanler)success failedBlock:(FailedHanler)failed {
    
    self = [super initCallback:callback withInfo:info];
    
    if (self)
    {
        self.successHandler = success;
        
        self.failedHandler = failed;
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (error.code == -1001)
    {
        self.resultInfo.requestError = HTTPNetworkTimedOut;
    }
    else
    {
        [self checkNetworkErrorCode];
    }
    
    [self displayNetworkStatus];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.failedHandler)
        {
            self.failedHandler(self.resultInfo);
            self.failedHandler = nil;
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    self.resultInfo.responseData = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.successHandler)
        {
            self.successHandler(self.resultInfo);
            self.successHandler = nil;
        }
    });
}

@end
