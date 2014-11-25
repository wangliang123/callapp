//
//  GKSipUser.h
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kGKSipUserNameKey;
extern NSString *kGKSipUserPasswordKey;
extern NSString *kGKSipUserServerKey;
extern NSInteger kGKSipUserPortKey;
@interface GKSipUser : NSObject

+ (GKSipUser *)shared;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *server;

@property (nonatomic, assign) BOOL userHasLogin;

@property (nonatomic,retain) NSTimer *timer;

- (BOOL)checkValid;
- (void)save;

@end
