//
//  HTTPConnection.m
//  Cartoon
//
//  Created by feng zhang on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HTTPConnection.h"
#import "CommonTask.h"
#import "CommonBlockTask.h"
#import "PhotoTask.h"
#import "DownloadTask.h"
#import "Reachability.h"

#define kPhotoMaxCount     60
#define kCOMMONMaxCount    60

@interface HTTPConnection ()

@property (nonatomic,strong) NSOperationQueue *COMMONQueue;
@property (nonatomic,strong) NSOperationQueue *PHOTOQueue;
@property (nonatomic,strong) NSOperationQueue *DOWNLOADQueue;

@end

static HTTPConnection *instance = nil;

@implementation HTTPConnection

- (id)init {
    
    self = [super init];
    if (self)
    {
        [FileOperation creatFolderForPhotoCache];
        
        self.COMMONQueue = [[NSOperationQueue alloc] init];
        self.COMMONQueue.maxConcurrentOperationCount = kCOMMONMaxCount;
        
        self.PHOTOQueue = [[NSOperationQueue alloc] init];
        self.PHOTOQueue.maxConcurrentOperationCount = kPhotoMaxCount;
        
        self.DOWNLOADQueue = [[NSOperationQueue alloc] init];
        self.DOWNLOADQueue.maxConcurrentOperationCount = kCOMMONMaxCount;
    }
    
    return self;
}

- (BOOL)checkNetworkConnection {
    
    struct sockaddr_in zeroAddress;
    
    bzero(&zeroAddress, sizeof(zeroAddress));
    
    zeroAddress.sin_len = sizeof(zeroAddress);
    
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Count not recover network reachability flags\n");
        
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (HTTPConnection *)HTTPInstance {
	
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[HTTPConnection alloc] init];
        }
    }
    
	return instance;
}

- (NSString *)URLEncode:(NSString *)str {
    
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)str,NULL,CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                                                                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString)
    {
		return newString;
	}
    
	return @"";
}

- (NSString *)URLDecoded:(NSString *)str {
    
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark DataSource

- (void)cancelDataRequest:(id)mark {
    
    NSArray *commons = [self.COMMONQueue operations];
    
    for (CommonTask *commonTask in commons)
    {
        [commonTask isCancelRequest:mark];
    }
}

- (void)cancelDataRequest:(id)mark withCode:(id)code {
    
    NSArray *commons = [self.COMMONQueue operations];
    
    for (CommonTask *commonTask in commons)
    {
        [commonTask isCancelRequest:mark withCode:code];
    }
}

- (void)requestData:(id)callback withInfo:(HTTPDetails *)requestInfo {
    
    [self.COMMONQueue addOperation:[[CommonTask alloc] initCallback:callback withInfo:requestInfo]];
}

- (void)requestData:(id)callback withInfo:(HTTPDetails *)requestInfo successBlock:(void(^)(id object))success failedBlock:(void(^)(id object))failed {
    
    [self.COMMONQueue addOperation:[[CommonBlockTask alloc] initCallback:callback withInfo:requestInfo successBlock:success failedBlock:failed]];
}

- (void)cancelAllRequest {

    NSArray *commons = [self.COMMONQueue operations];
    
    for (CommonTask *commonTask in commons)
    {
        [commonTask cancelRequest];
    }
}

#pragma mark -
#pragma mark Photo Methods

- (void)cancelPhotoView:(id)mark {
    
    NSArray *pictures = [self.PHOTOQueue operations];
    
    for (PhotoTask *photoTask in pictures)
    {
        [photoTask isCancelPhotoView:mark];
    }
}

- (void)cancelPhotoController:(id)mark {
    
    NSArray *pictures = [self.PHOTOQueue operations];
    
    for (PhotoTask *photoTask in pictures)
    {
        [photoTask isCancelPhotoController:mark];
    }
}

- (void)requestPhoto:(id)callback controller:(id)controller withInfo:(HTTPDetails *)requestInfo {

    [self.PHOTOQueue addOperation:[[PhotoTask alloc] initCallback:callback controller:controller withInfo:requestInfo]];
}

#pragma mark -
#pragma mark Download Methods

- (void)downloadData:(id)callback withInfo:(HTTPDetails *)requestInfo {

}

@end
