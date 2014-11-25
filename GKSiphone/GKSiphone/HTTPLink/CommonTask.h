//
//  CommonTask.h
//  SUNTV
//
//  Created by zf tank on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

@class HTTPDetails;

@interface CommonTask : NSOperation <NSURLConnectionDelegate>

@property (nonatomic,strong,readonly) id callBack;
@property (nonatomic,strong,readonly) HTTPDetails *resultInfo;
@property (nonatomic,copy,readonly) NSString *requestUrl;
@property (nonatomic,strong,readonly) NSMutableData *responseData;
@property (nonatomic,strong,readonly) NSMutableURLRequest *request;

- (void)isCancelRequest:(id)callback;
- (void)isCancelRequest:(id)callback withCode:(id)code;
- (id)initCallback:(id)callback withInfo:(HTTPDetails *)requestInfo;

- (void)checkNetworkErrorCode;
- (void)displayNetworkStatus;

- (void)cancelRequest;

@end
