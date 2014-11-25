//
//  CommonBlockTask.h
//  MarketWork
//
//  Created by 陈扬 on 14-5-13.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "CommonTask.h"

typedef void(^SuccessHanler)(id object);
typedef void(^FailedHanler)(id object);

@interface CommonBlockTask : CommonTask <NSURLConnectionDelegate>

@property (nonatomic,copy,readonly) SuccessHanler successHandler;
@property (nonatomic,copy,readonly) FailedHanler failedHandler;

- (id)initCallback:(id)callback withInfo:(HTTPDetails *)info successBlock:(SuccessHanler)success failedBlock:(FailedHanler)failed;

@end
