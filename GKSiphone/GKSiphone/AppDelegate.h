//
//  AppDelegate.h
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKSip.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"
#import "GKActiveCallViewController.h"
#import "FileManager.h"
#import "MarketEntity.h"
#import "HTTPConnection.h"
#import "ServerManager.h"
#import "Config.h"

#define APPDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, ATMHudDelegate,UIAlertViewDelegate>
{
    NSString *InfoStr;

}


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabViewController;
@property (strong, nonatomic) GKActiveCallViewController *activeCallVC;
@property (strong, nonatomic) ATMHud *atmHud;
//@property (nonatomic, assign) NSInteger CallId;

- (void)showMsg:(NSString *)aMsg
      isLoading:(BOOL)aIsLoading
      hideAfter:(NSTimeInterval)aDelay;
- (void)hideMsg;

- (void)login;
- (void)logout;

- (void)handleIncommingCall:(NSInteger)aCallId
                   callName:(NSString *)aCallName;

- (void)makeCall:(NSString *)aCallUrl;
- (void)answerCall:(NSInteger)aCallId;
- (void)endCall:(NSInteger)aCallId;

- (void)addRootController;

@end

extern NSString *kGKSipUserLoginStateChange;

#define GKAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
