//
//  GKSipLogDB.h
//  GKSiphone
//
//  Created by Guogang on 13-1-27.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class GKSipLog;

@interface GKSipLogDB : NSObject
{
    FMDatabase		*_db;
	NSString		*_dbPath;
}

+ (GKSipLogDB *)shared;

- (void)insertLog:(GKSipLog *)aLog;
- (void)removeLogWithStartTime:(double)aStartTime;
- (NSArray *)allLogs;

@end
