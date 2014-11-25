//
//  GKSipLog.h
//  GKSiphone
//
//  Created by Guogang on 13-1-27.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKSipLog : NSObject

@property (nonatomic, assign) NSInteger logId;
@property (nonatomic, strong) NSString *callName;
@property (nonatomic, strong) NSString *callID;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double finishedTime;
@property (nonatomic, assign) int callType; // 0：呼叫 1：被叫 2：未接

@end
