//
//  CommonTask.m
//  SUNTV
//
//  Created by zf tank on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommonTask.h"
#import "HTTPConnection.h"

#define kTimeOut           3.0f
#define kCustomerIdKey     @"customerId"
#define kClientAgentKey    @"clientAgent"
#define kVersionIdKey      @"versionId"
#define kModelKey          @"model"
#define kUserIdKey         @"userId"
#define kAgencyKey         @"agency"
#define kInterfaceKey      @"interface"
#define kTokenKey          @"token"
#define kPushTokenKey      @"deviceId"
#define kClientTestKey     @"clientTest"

@interface CommonTask ()

@property (nonatomic,strong) id callBack;
@property (nonatomic,strong) HTTPDetails *resultInfo;
@property (nonatomic,copy)   NSString *requestUrl;
@property (nonatomic,strong) NSMutableData *responseData;
@property (nonatomic,strong) NSMutableURLRequest *request;
@property (nonatomic,strong) NSURLConnection *connection;

- (void)cancelRequest;
- (BOOL)atOperations:(id)mark;
- (BOOL)isRequestCode:(id)code;

@end

@implementation CommonTask

- (id)initCallback:(id)callback withInfo:(HTTPDetails *)requestInfo {
    
    self.callBack = callback;
    self.resultInfo = requestInfo;
    self.requestUrl = [self.resultInfo.requestHost stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self = [super init];
    
    if (self)
    {
        self.request = [[NSMutableURLRequest alloc] init];
        
        [self.request setURL:[NSURL URLWithString:self.requestUrl]];
        
        [self.request setTimeoutInterval:kTimeOut];
    }
    
    return self;
}

- (void)dealloc {

    self.callBack = nil;
    
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
    
    if (error.code == -1001)
    {
        self.resultInfo.requestError = HTTPNetworkTimedOut;
    }
    else
    {
        [self checkNetworkErrorCode];
    }

    if ([self.callBack respondsToSelector:@selector(requestWrong:)])
    {
        [self.callBack performSelectorOnMainThread:@selector(requestWrong:) withObject:self.resultInfo waitUntilDone:NO];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.resultInfo.responseData = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
    
    if ([self.callBack respondsToSelector:@selector(requestSucces:)])
    {
        [self.callBack performSelectorOnMainThread:@selector(requestSucces:) withObject:self.resultInfo waitUntilDone:NO];
    }
}

- (void)checkNetworkErrorCode {

    self.resultInfo.requestError = HTTPNotNetwork;
}

- (void)displayNetworkStatus {

    
}

#pragma mark -
#pragma mark CancleRequest Methods

- (void)isCancelRequest:(id)callback {

    if ([self atOperations:callback])
    {
        [self cancelRequest];
    }
}

- (void)isCancelRequest:(id)callback withCode:(id)code {

    if ([self atOperations:callback])
    {
        if ([self isRequestCode:code])
        {
            [self cancelRequest];
        }
    }
}

- (BOOL)atOperations:(id)mark {
    
    return [self.callBack isEqual:mark];
}

- (BOOL)isRequestCode:(id)code {

    return [self.resultInfo.requestInterface isEqual:code];
}

- (void)cancelRequest {
    
    [self.connection cancel];
    
    [self cancel];
}

@end
