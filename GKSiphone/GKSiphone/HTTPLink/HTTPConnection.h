//
//  HTTPConnection.h
//  Cartoon
//
//  Created by feng zhang on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPDetails.h"
#import "FileOperation.h"
#import "UIButton+Photo.h"
#import "UIImageView+Photo.h"

#define HTTPLink  [HTTPConnection HTTPInstance]

@interface HTTPConnection : NSObject

- (BOOL)checkNetworkConnection;//判断网络是否可用

#pragma mark -
#pragma mark DataSource

- (void)cancelAllRequest;

- (void)cancelDataRequest:(id)mark;
- (void)cancelDataRequest:(id)mark withCode:(id)code;
- (void)requestData:(id)callback withInfo:(HTTPDetails *)requestInfo;//请求数据
- (void)requestData:(id)callback withInfo:(HTTPDetails *)requestInfo successBlock:(void(^)(id object))success failedBlock:(void(^)(id object))failed;//BLOCK形式请求数据

#pragma mark -
#pragma mark Photo Methods

- (void)cancelPhotoView:(id)mark;
- (void)cancelPhotoController:(id)mark;
- (void)requestPhoto:(id)callback controller:(id)controller withInfo:(HTTPDetails *)requestInfo;//请求图片

#pragma mark -
#pragma mark Download Methods

- (void)downloadData:(id)callback withInfo:(HTTPDetails *)requestInfo;//下载数据

#pragma mark -
#pragma mark HTTPLink

+ (HTTPConnection *)HTTPInstance;

- (NSString *)URLEncode:(NSString *)str;

- (NSString *)URLDecoded:(NSString *)str;

@end

@protocol HTTPDelegate <NSObject>

- (void)requestSucces:(HTTPDetails *)details;

- (void)requestWrong:(HTTPDetails *)details;

@end
