//
//  DownloadTask.m
//  GJDD
//
//  Created by zftank on 14-9-10.
//  Copyright (c) 2014年 zftank. All rights reserved.
//

#import "DownloadTask.h"

@implementation DownloadTask

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if ([self.callBack respondsToSelector:@selector(requestSucces:)])
    {
        [self.callBack performSelectorOnMainThread:@selector(requestSucces:) withObject:self.resultInfo waitUntilDone:NO];
    }
}

@end
