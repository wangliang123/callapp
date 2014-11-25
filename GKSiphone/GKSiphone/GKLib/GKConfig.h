//
//  GKConfig.h
//  GKSiphone
//
//  Created by Guogang on 13-1-18.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(objc_arc)
#define GK_PROP_RETAIN strong
#define GK_RETAIN(x) (x)
#define GK_RELEASE(x)
#define GK_AUTORELEASE(x)
#define GK_BLOCK_COPY(x) (x)
#define GK_BLOCK_RELEASE(x)
#define GK_SUPER_DEALLOC()
#define GK_AUTORELEASE_POOL_START() @autoreleasepool {
#define GK_AUTORELEASE_POOL_END() }
#else
#define GK_PROP_RETAIN retain
#define GK_RETAIN(x) ([(x) retain])
#define GK_RELEASE(x) ([(x) release])
#define GK_AUTORELEASE(x) ([(x) autorelease])
#define GK_BLOCK_COPY(x) (Block_copy(x))
#define GK_BLOCK_RELEASE(x) (Block_release(x))
#define GK_SUPER_DEALLOC() ([super dealloc])
#define GK_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#define GK_AUTORELEASE_POOL_END() [pool release];
#endif

extern NSString* GKCacheDocument(void);
