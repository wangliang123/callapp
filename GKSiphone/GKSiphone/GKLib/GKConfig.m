//
//  GKConfig.m
//  GKSiphone
//
//  Created by Guogang on 13-1-18.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKConfig.h"

NSString* GKCacheDocument(void)
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}