//
//  PhotoTask.m
//  BeautyGirl
//
//  Created by zhangfeng on 12-11-22.
//  Copyright (c) 2012年 zftank. All rights reserved.
//

#import "PhotoTask.h"
#import "HTTPConnection.h"

#define kTrySpace     100
#define kTimeOut      10.0f

@interface PhotoTask ()

@property (nonatomic,strong) id callBack;
@property (nonatomic,strong) id theController;
@property (nonatomic,strong) HTTPDetails *resultInfo;
@property (nonatomic,strong) NSMutableData *responseData;
@property (nonatomic,strong) NSMutableURLRequest *request;
@property (nonatomic,strong) NSURLConnection *connection;

- (void)cancelRequest;
- (void)wrongForRequestPhoto;
- (void)retryRequestImage;

@end

@implementation PhotoTask

- (id)initCallback:(id)callback controller:(id)controller withInfo:(HTTPDetails*)requestInfo {
    
    self.callBack = callback;
    self.theController = controller;
    self.resultInfo = requestInfo;
        
    self = [super init];
    
    if (self)
    {
        self.request = [[NSMutableURLRequest alloc] init];
        
        [self.request setURL:[NSURL URLWithString:self.resultInfo.requestHost]];

        [self.request setTimeoutInterval:kTimeOut];
    }
    
    return self;
}

- (void)dealloc {
    
    self.callBack = nil;
    
    self.theController = nil;
    
    self.connection = nil;
    
    self.responseData = nil;
}

- (void)main {
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.connection start];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)aResponse;
    self.resultInfo.responseHeader = httpResponse.allHeaderFields;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    if ([self.callBack respondsToSelector:@selector(requestWrong:)])
    {
        [self.callBack performSelectorOnMainThread:@selector(requestWrong:) withObject:self.resultInfo waitUntilDone:NO];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    UIImage *responseImage = [UIImage imageWithData:self.responseData];
    
    if (responseImage)
    {
        self.resultInfo.responseData = responseImage;
        
        [self.responseData writeToFile:self.resultInfo.cachePhoto atomically:YES];
        
        if ([self.callBack respondsToSelector:@selector(requestSucces:)])
        {
            [self.callBack performSelectorOnMainThread:@selector(requestSucces:) withObject:self.resultInfo waitUntilDone:NO];
        }
    }
    else
    {
        [self wrongForRequestPhoto];
    }
}

- (void)wrongForRequestPhoto {
    
    if (self.resultInfo.requestError <= kTrySpace)
    {
        self.resultInfo.requestError = kTrySpace + self.resultInfo.requestError;
        
        [self retryRequestImage];
    }
    else
    {
        if ([self.callBack respondsToSelector:@selector(requestWrong:)])
        {
            [self.callBack performSelectorOnMainThread:@selector(requestWrong:) withObject:self.resultInfo waitUntilDone:NO];
        }
    }
    
    [self cancel];
}

- (void)retryRequestImage {
    
    [HTTPLink requestPhoto:self.callBack controller:self.theController withInfo:self.resultInfo];
}

#pragma mark -
#pragma mark CancleRequest Methods

- (void)isCancelPhotoView:(id)mark {

    if ([self.callBack isEqual:mark])
    {
        [self cancelRequest];
    }
}

- (void)isCancelPhotoController:(id)mark {
    
    if ([self.theController isEqual:mark])
    {
        [self cancelRequest];
    }
}

- (void)cancelRequest {
    
    [self.connection cancel];
    
    [self cancel];
}

@end
