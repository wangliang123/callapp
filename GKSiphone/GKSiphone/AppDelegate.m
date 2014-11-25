//
//  AppDelegate.m
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "AppDelegate.h"

#import "GKCallViewController.h"
#import "GKSettingViewController.h"
#import "GKLogViewController.h"
#import "GKContactViewController.h"
#import "GKPwdViewController.h"
#import "GKActiveCallViewController.h"
#import "GKOnlineViewController.h"
#import "GKSipUser.h"
#import "GKSipLog.h"

@interface SipServerInfo : NSObject
{

    NSString *ip;
    NSInteger port;
}

-(SipServerInfo*) initWithAddress:(NSString*) server;
-(NSString*) getServerIp;
-(NSInteger) getServerPort;
@end

@implementation SipServerInfo
- (id)init
{
    self = [super init];
    
    if (self)
    {
       
    }
    
    return self;
}
-(SipServerInfo*) initWithAddress:(NSString *)server
{
    self = [super init];
    if (self) {
        NSArray *tmp = [server componentsSeparatedByString:@":"];
        NSInteger len =[tmp count];
        if (len>2) {
            [NSException raise:@"服务器地址格式错误" format:nil];
        }
        
        self->ip = [tmp objectAtIndex:0];
        self->port = 5060;
        
        if (len==2) {
            @try {
                self->port = [[tmp objectAtIndex:1] intValue];
            }
            @catch (NSException *exception) {
                [NSException raise:@"服务器端口号格式错误" format:nil];
            }
        }
    }
    return self;
    
}

-(NSString*) getServerIp
{
    return self->ip;
}

-(NSInteger) getServerPort
{
    return self->port;
}
@end

typedef enum _EGKLoginFlag
{
    EGKLoginFlagIdle = 0,
    EGKLoginFlagLogin = 1 << 0,
    EGKLoginFlagLogout = 1 << 1,
} EGKLoginFlag;

NSString *kGKSipUserLoginStateChange = @"kGKSipUserLoginStateChange";

@interface AppDelegate ()

@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, assign) NSInteger callId;
@property (nonatomic, assign) NSInteger loginFlag;

@property (nonatomic,retain) NSDictionary *launchInfo;

@end

#define kAlertViewCallTag 1001

@implementation AppDelegate
//@synthesize CallId;
- (void)dealloc
{
    GK_RELEASE(_window);
    GK_RELEASE(_callViewController);
    GK_RELEASE(_tabViewController);
    GK_RELEASE(activeCallVC);
    GK_SUPER_DEALLOC();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.launchInfo = launchOptions;
    
    //[ServerCenter startSearchServer:self];
    
    [self addRootController];
    
    
    return YES;
}

- (void)succesForServer {

    [self addRootController];
}

- (void)addRootController {

    self.tabViewController = [[UITabBarController alloc] init];
    
    
    GKCallViewController *callViewController = [[GKCallViewController alloc] initWithNibName:@"GKCallViewController" bundle:nil];
    callViewController.tabBarItem.title = @"拨号键盘";
    callViewController.tabBarItem.image = [UIImage imageNamed:@"dialer.png"];
    GKLogViewController *logoViewController = [[GKLogViewController alloc] initWithNibName:@"GKLogViewController" bundle:nil];
    UINavigationController *logoNav = [[UINavigationController alloc] initWithRootViewController:logoViewController];
    GK_RELEASE(logoViewController);
    logoNav.tabBarItem.title = @"最近通话";
    logoNav.tabBarItem.image = [UIImage imageNamed:@"recents.png"];
    
    GKContactViewController *contactViewController = [[GKContactViewController alloc] initWithNibName:@"GKContactViewController" bundle:nil];
    UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    GK_RELEASE(contactViewController);
    contactNav.tabBarItem.title = @"通讯录";
    contactNav.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    self.tabViewController.viewControllers = [NSArray arrayWithObjects:logoNav, contactNav, callViewController, nil];
    self.window.rootViewController = self.tabViewController;
    GK_RELEASE(logoNav);
    GK_RELEASE(contactNav);
    GK_RELEASE(callViewController);
    GK_AUTORELEASE(self.tabViewController);
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    self.isBackground = YES;

    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{GKSipClient_SetBackgroundMode(NO);}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    self.isBackground = NO;

    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{GKSipClient_SetBackgroundMode(NO);}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ([notification.userInfo objectForKey:@"callId"] != nil)
    {
        NSInteger call_id = [[notification.userInfo objectForKey:@"callId"] integerValue];
        NSString *info = [notification.userInfo objectForKey:@"info"];
     
        [GKAppDelegate handleIncommingCall:call_id callName:info];
    }
}

static void on_call_incoming_background(pjsua_call_info* call_info)
{


    
}

static void on_call_incoming(pjsua_call_info* call_info)
{


    char caller[256] = {'0'};
    
    // 获取主叫方的账号信息
    pjstr_to_char(caller, 256, &call_info->remote_info);
    
    NSString *removeInfo = [NSString stringWithUTF8String:caller];
    NSArray *rt = [removeInfo componentsSeparatedByString:@"\""];

    if (rt.count > 2)
        removeInfo = [rt objectAtIndex:1];
        
    [GKAppDelegate handleIncommingCall:call_info->id
                              callName:removeInfo];
}

// sip呼叫事件
static void OnSipCall(pjsua_call_info* call_info)
{


    switch (call_info->state) {
        case PJSIP_INV_STATE_CALLING:
        {
            // 呼叫中
        }
            break;
        case PJSIP_INV_STATE_INCOMING:
        {
            // 呼入
            GKAppDelegate.callId = call_info->id;
            NSLog(@"%d",call_info->id);
            if (GKAppDelegate.isBackground)
            {
                on_call_incoming_background(call_info);
            }
            else
            {
                on_call_incoming(call_info);
            }            
        }
            break;
        case PJSIP_INV_STATE_EARLY:
        {
            // 对方已响铃
        }
            break;
        case PJSIP_INV_STATE_CONNECTING:
        {
            // 呼叫建立连接中
        }
            break;
        case PJSIP_INV_STATE_CONFIRMED:
        {
            [GKAppDelegate.activeCallVC setUIState:EGKActiveCallUIStateCalling];
        }
            break;
        case PJSIP_INV_STATE_DISCONNECTED:
        {
            // 呼叫挂断
            [GKAppDelegate.activeCallVC setUIState:EGKActiveCallUIStateDisconnect];
        }
            break;
        default:
            break;
    }

}

// 账户状态, 注册/注销执行状态
static void GKsip_on_account_state(const GKSipClientStateInfo* aStateInfo)
{

    
    if (aStateInfo->code == GKSip_SC_OK)
    {
        switch (aStateInfo->state) {
            case GKSipAccountStateOnline:
            {     
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GKSipUser shared].userHasLogin = YES;
                    
                    if (GKAppDelegate.loginFlag == EGKLoginFlagLogin)
                    {
                        [GKAppDelegate showMsg:@"账户登录成功" isLoading:NO hideAfter:1.0];
                        GKAppDelegate.loginFlag = EGKLoginFlagIdle;
                        
                        [[GKSipUser shared] save];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGKSipUserLoginStateChange
                                                                        object:nil];
                });
            }
                break;
            case GKSipAccountStateInProcess:
            {}
                break;
            case GKSipAccountStateOffline:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [GKSipUser shared].userHasLogin = NO;
                    
                    if (GKAppDelegate.loginFlag == EGKLoginFlagLogin)
                    {
                        [GKAppDelegate showMsg:@"账户登录失败"
                                     isLoading:NO
                                     hideAfter:1.0];
                        GKAppDelegate.loginFlag = EGKLoginFlagIdle;
                    }
                    else if (GKAppDelegate.loginFlag == EGKLoginFlagLogout)
                    {
                        [GKAppDelegate showMsg:@"账户已注销"
                                     isLoading:NO
                                     hideAfter:1.0];
                        
                        GKAppDelegate.loginFlag = EGKLoginFlagIdle;
                    }
                               
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGKSipUserLoginStateChange
                                                                                   object:nil];
                });
            }
                break;
            case GKSipAccountStateUnknown:
            {
            
            }
                break;
            default:
                break;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [GKSipUser shared].userHasLogin = NO;
            
            if (GKAppDelegate.loginFlag == EGKLoginFlagLogin)
            {
                [GKAppDelegate showMsg:@"账户登录失败" isLoading:NO hideAfter:1.0];
                GKAppDelegate.loginFlag = EGKLoginFlagIdle;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGKSipUserLoginStateChange
                                                                object:nil];
        });
    }
}

// Call相关的状态
static void GKsip_on_call_state(const int call_id,
                                const GKSipClientStateInfo* aStateInfo)
{


    dispatch_async(dispatch_get_main_queue(), ^{
        switch (aStateInfo->state) {
            case GKSipCallStateIncoming:
            {
                GKAppDelegate.callId = call_id;
                NSLog(@"%d",call_id);
                if (GKAppDelegate.isBackground)
                {
                    
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    if (notification) {
                        notification.repeatInterval = 0;
                        
                        NSString *removeInfo = [NSString stringWithUTF8String:aStateInfo->info];
                        NSArray *rt = [removeInfo componentsSeparatedByString:@"\""];
                        if (rt.count > 2)
                        {
                            removeInfo = [rt objectAtIndex:1];
                        }
                        
                        notification.alertBody = [NSString stringWithFormat:@"来电[%@]", removeInfo];

                        notification.hasAction = NO;
                        notification.soundName = @"ring.caf";
                        notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", call_id], @"callId", removeInfo, @"info", nil];
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

                    }
                    
                }
                else
                {
                    
                    NSString *removeInfo = [NSString stringWithUTF8String:aStateInfo->info];
                    NSArray *rt = [removeInfo componentsSeparatedByString:@"\""];
                    if (rt.count > 2)
                    {
                        removeInfo = [rt objectAtIndex:1];
                    }
                    
                    
                    [GKAppDelegate handleIncommingCall:call_id
                                              callName:removeInfo];
                }
            }
                break;
            case GKSipCallStateCalling:
            {
            
            }
                break;
            case GKSipCallStateConfirmed:
            {
                [GKAppDelegate.activeCallVC setUIState:EGKActiveCallUIStateCalling];
            }
                break;
            case GKSipCallStateDisconnected:
            {
                [GKAppDelegate.activeCallVC setUIState:EGKActiveCallUIStateDisconnect];
                [[UIApplication sharedApplication] cancelAllLocalNotifications];

            }
                break;
        };

    });
    
}

- (void)showMsg:(NSString *)aMsg
      isLoading:(BOOL)aIsLoading
      hideAfter:(NSTimeInterval)aDelay
{


    [self.atmHud setCaption:aMsg];
    [self.atmHud setActivity:aIsLoading];
    [self.atmHud show];
    if (aDelay)
    {
        [self.atmHud hideAfter:aDelay];
    }
}

- (void)hideMsg {
    
    [self.atmHud hide];
}

- (void)login {
    
    NSString *input = [GKSipUser shared].server;
    
    if ([[GKSipUser shared] checkValid])
    {
        @try
        {
            SipServerInfo *info = [[SipServerInfo alloc]initWithAddress:input];
            
            GKSipClient_Register([[GKSipUser shared].userName UTF8String],
                                 [[GKSipUser shared].userName UTF8String],
                                 [[GKSipUser shared].password UTF8String],
                                 [[info getServerIp] UTF8String],
                                 [info getServerPort]);
            
            [self showMsg:@"账户登录中, 请等候..." isLoading:YES hideAfter:0];
            
            self.loginFlag = EGKLoginFlagLogin;
        }
        @catch (NSException *ex)
        {
            [self showMsg:ex.reason isLoading:NO hideAfter:5];
        }
    }
    else
    {
        GKPwdViewController *vc = [[GKPwdViewController alloc] initWithNibName:@"GKPwdViewController" bundle:nil];
        vc.isModelViewController = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        GK_RELEASE(vc);
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        {
            [self.tabViewController presentViewController:nav animated:YES completion:nil];
        }
        else
        {
            [self.tabViewController presentModalViewController:nav animated:YES];
        }
        
        GK_RELEASE(nav);
    }
}

- (void)logout
{


    GKSipClient_Unregister((const char*)[[GKSipUser shared].userName UTF8String]);
    
    [self showMsg:@"账户注销中, 请等候..." isLoading:YES hideAfter:0];
    
    self.loginFlag = EGKLoginFlagLogout;
}

- (void)handleIncommingCall:(NSInteger)aCallId
                   callName:(NSString *)aCallName
{


    if (self.activeCallVC == nil)
    {
        self.activeCallVC = [[GKActiveCallViewController alloc] init];
        self.activeCallVC.callId = aCallId;
        self.activeCallVC.UIState = EGKActiveCallUIStateIncoming;
        self.activeCallVC.callName = aCallName;
        self.activeCallVC.isIncomming = YES;
        
   if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        {
            [self.tabViewController presentViewController:self.activeCallVC animated:NO completion:nil];
        }
        else
        {
            [self.tabViewController presentModalViewController:self.activeCallVC animated:NO];
        }
        

    }
    else
    {
        GKSipClient_Hangup(aCallId, GKSipClientHangupBusy);
    }

}

- (void)makeCall:(NSString *)aCallUrl
{

    
    if ([[GKSipUser shared].userName isEqualToString:aCallUrl])
    {
        [self showMsg:@"不能呼叫自己" isLoading:NO hideAfter:1.0];
        return;

    }
    
    if (self.activeCallVC != nil)
    {
        return;
    }
    
    int callId;
    GKsip_status_t status = GKSipClient_MakeCall([aCallUrl UTF8String], &callId);
    
    if (status == GKSIP_SUCCESS)
    {
        GKActiveCallViewController *vc = [[GKActiveCallViewController alloc] init];
        vc.callId = callId;
        vc.UIState = EGKActiveCallUIStateMakeCall;
        vc.callName = aCallUrl;
        vc.isIncomming = NO;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.activeCallVC = vc;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        {
            [self.tabViewController presentViewController:self.activeCallVC animated:YES completion:nil];
        }
        else
        {
            [self.tabViewController presentModalViewController:self.activeCallVC animated:YES];
        }
    }
    else
    {
        [self showMsg:@"呼叫失败, 请重试" isLoading:NO hideAfter:1.0];
    }
}

- (void)answerCall:(NSInteger)aCallId
{


    GKSipClient_Anwser(aCallId);
}

- (void)endCall:(NSInteger)aCallId
{


    GKSipClient_Hangup(aCallId, GKSipClientHangupBusy);
    
}

@end
