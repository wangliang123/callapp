//
//  GKSipUser.m
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKSipUser.h"

NSString *kGKSipUserNameKey = @"kGKSipUserNameKey";
NSString *kGKSipUserPasswordKey = @"kGKSipUserPasswordKey";
NSString *kGKSipUserServerKey = @"kGKSipUserServerKey";



@implementation GKSipUser

+ (GKSipUser *)shared
{
    static GKSipUser *sipUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sipUser = [[GKSipUser alloc] init];
    });
    
    return sipUser;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kGKSipUserNameKey];
        if (userName)
        {
            self.userName = userName;
        }
        
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kGKSipUserPasswordKey];
        if (password)
        {
            self.password = password;
        }
        
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:kGKSipUserServerKey];
        if (server)
        {
            self.server = server;
        }

    }
    
    return self;

}

- (void)dealloc
{
    self.userName = nil;
    self.password = nil;
    self.server = nil;

    GK_SUPER_DEALLOC();
}

- (BOOL)checkValid
{
    return self.userName && [self.userName isEqualToString:@""] == NO && self.password && [self.password isEqualToString:@""] == NO && self.server && [self.server isEqualToString:@""] == NO;
}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:self.userName forKey:kGKSipUserNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:kGKSipUserPasswordKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.server forKey:kGKSipUserServerKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(hearbeat:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)hearbeat:(id)send {
    
    HTTPDetails *infomation = [[HTTPDetails alloc] init];
    infomation.requestHost = [NSString stringWithFormat:@"http://%@/api/heartbeat/%@",ServerCenter.infomation.serverIP,self.userName];
    [HTTPLink requestData:self withInfo:infomation];
}

- (void)requestSucces:(HTTPDetails *)details {
    
   NSLog(@"requestSucces");
}

- (void)requestWrong:(HTTPDetails *)details {
    
    NSLog(@"requestWrong");
}


@end
