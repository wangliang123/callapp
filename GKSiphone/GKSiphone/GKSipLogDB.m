//
//  GKSipLogDB.m
//  GKSiphone
//
//  Created by Guogang on 13-1-27.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKSipLogDB.h"
#import "FMDatabase.h"
#import "GKSipLog.h"

@implementation GKSipLogDB

+ (GKSipLogDB *)shared
{
    static GKSipLogDB *logBD = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logBD = [[GKSipLogDB alloc] init];
    });
    
    return logBD;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSString *dbPath = [NSString stringWithFormat:@"%@/GKSip.db", GKCacheDocument()];
        [self buildDbWithPath:dbPath];
    }
    
    return self;
}

- (void)dealloc
{
    GK_RELEASE(_db);
    _db = nil;
    
    GK_RELEASE(_dbPath);
    _dbPath = nil;
    
    GK_SUPER_DEALLOC();
}

- (void)insertLog:(GKSipLog *)aLog
{
    NSString *sql = @"INSERT INTO gksip_log(name,CallID, type ,startTime, endTime) VALUES (?, ?, ?, ?, ?)";
	
	[_db executeUpdate:sql withArgumentsInArray:[NSArray arrayWithObjects:
                                                 [self checkString:aLog.callName],[NSNumber numberWithInt:aLog.logId],
                                                 [NSNumber numberWithInt:aLog.callType],
												 [NSNumber numberWithDouble:aLog.startTime],
                                                 [NSNumber numberWithDouble:aLog.finishedTime],
												 nil]];
	
	[self checkErr:_db];
    
}

- (void)removeLogWithStartTime:(double)aStartTime
{
    NSString* sql = @"delete from gksip_log where startTime = ?";
	
	[_db executeUpdate:sql, [NSNumber numberWithDouble:aStartTime]];
	[self checkErr:_db];
}

- (NSArray *)allLogs
{
    NSMutableArray *allLog = [NSMutableArray arrayWithCapacity:0];
    
    NSString *sql = @"SELECT * FROM gksip_log order by startTime DESC";
	
    FMResultSet *rs = [_db executeQuery:sql];
	
    while ([rs next])
    {
		GKSipLog *siglog = [[GKSipLog alloc] init];
		siglog.callName = [rs stringForColumnIndex:0];
        siglog.logId = [rs intForColumnIndex:1];
        siglog.callType = [rs intForColumnIndex:2];
        siglog.startTime = [rs doubleForColumnIndex:3];
        siglog.finishedTime = [rs doubleForColumnIndex:4];
        
        [allLog addObject:siglog];
        GK_RELEASE(siglog);
    }
    [rs close];
    
    return allLog;
}

- (void)buildDbWithPath:(NSString *)aDbPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    _dbPath = [[NSString alloc] initWithString:aDbPath];
    
    BOOL isCreateTable = NO;
    if ([fm fileExistsAtPath:_dbPath] == NO)
    {
        isCreateTable = YES;
    }
    
    _db = [[FMDatabase alloc] initWithPath:_dbPath];
    if ([_db open])
    {
        [_db setShouldCacheStatements:YES];
        
        if (isCreateTable)
        {
            [self createTable];
        }
    }
    else
    {
        NSLog(@"Failed to open database.");
    }
}

- (void)checkErr:(FMDatabase *)aDb
{
    if ([aDb hadError])
	{
		NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
	}
}

- (NSString *)checkString:(NSString *)aString
{
	return aString ? aString : @"";
}

- (void)createTableWithSQLStatement:(NSString *)aStatement
{
	[_db executeUpdate:aStatement];
	[self checkErr:_db];
}


- (void)createLogTable
{
    [self createTableWithSQLStatement:@"CREATE TABLE gksip_log (name varchar(128),CallId varchar(128), type int, startTime double, endTime double, PRIMARY KEY (startTime))"];
	
	[self createTableWithSQLStatement:@"CREATE INDEX index_startTime ON gksip_log (startTime)"];
}
- (void)createTable
{   
    [self createLogTable];
}

@end
