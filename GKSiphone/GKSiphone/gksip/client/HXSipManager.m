//
//  HXSipManager.m
//  HXSip
//
//  Created by Stupid on 12-10-29.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#import "HXSipManager.h"

@implementation HXSipManagerStateInfo

@synthesize state;
@synthesize code;
@synthesize warning;
@synthesize removeInfo;

- (void)dealloc
{
    self.warning = nil;
    self.removeInfo = nil;
    [super dealloc];
}

@end

@implementation HXSipManagerMemo

@synthesize callId;
@synthesize accoundId;
@synthesize roomId;

@end

@interface HXSipManager()

@property (nonatomic, retain) HXSipManagerMemo *sipMemo;

- (id<HXSipManagerDelegate>)delegateAtIndex:(NSInteger)aIndex;

@end

@implementation HXSipManager

+ (HXSipManager *)shareManager
{    
    static HXSipManager *sipManager = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sipManager = [[HXSipManager alloc] init];

        sipManager.sipMemo = [[[HXSipManagerMemo alloc] init] autorelease];
        sipManager.sipMemo.callId = -1;
        sipManager.sipMemo.accoundId = -1;
        sipManager.sipMemo.roomId = -1;
    });
    
    return sipManager;
}

- (id<HXSipManagerDelegate>)delegateAtIndex:(NSInteger)aIndex
{
    return _listeners[aIndex];
}

- (HXSipManagerMemo *)memo
{
    return self.sipMemo;
}

// 账户状态, 注册/注销执行状态
static void hxsip_on_account_state(const HXSipClientStateInfo* aStateInfo)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXSipManager *sipManager = [HXSipManager shareManager];
        
        HXSipManagerStateInfo *stateInfo = [[[HXSipManagerStateInfo alloc] init] autorelease];
        stateInfo.state = aStateInfo->state;
        stateInfo.code = aStateInfo->code;
        
        for (NSInteger index = 0; index < kListenerCount; ++index)
        {
            id<HXSipManagerDelegate> listener = [sipManager delegateAtIndex:index];
            if ([listener respondsToSelector:@selector(hxSipManager:accountStateInfo:)])
            {
                [listener hxSipManager:sipManager
                      accountStateInfo:stateInfo];
            }
        }
    });
}


// Call相关的状态
static void hxsip_on_call_state(const int call_id,
                                const HXSipClientStateInfo* aStateInfo)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HXSipManager *sipManager = [HXSipManager shareManager];
        
        HXSipManagerStateInfo *stateInfo = [[[HXSipManagerStateInfo alloc] init] autorelease];
        stateInfo.state = aStateInfo->state;
        stateInfo.code = aStateInfo->code;
        
        NSString *removeInfo = [NSString stringWithUTF8String:aStateInfo->info];
        NSArray *rt = [removeInfo componentsSeparatedByString:@"\""];
        if (rt.count > 2)
        {
            stateInfo.removeInfo = [rt objectAtIndex:1];
        }
        
        
        for (NSInteger index = 0; index < kListenerCount; ++index)
        {
            id<HXSipManagerDelegate> listener = [sipManager delegateAtIndex:index];
            if ([listener respondsToSelector:@selector(hxSipManager:callId:callStateInfo:)])
            {
                [listener hxSipManager:sipManager
                                callId:call_id
                         callStateInfo:stateInfo];
            }
        }
    });
}

- (void)addListener:(id<HXSipManagerDelegate>)aListener
{
    //[self.listeners addObject:aListener];
    for (NSInteger index = 0; index < kListenerCount; ++index)
    {
       if (_listeners[index] == nil)
       {
           _listeners[index] = aListener;
           break;
       }
    }
}

- (void)removeListener:(id<HXSipManagerDelegate>)aListener
{
    //[self.listeners removeObject:aListener];
    
    for (NSInteger index = 0; index < kListenerCount; ++index)
    {
        if (_listeners[index] == aListener)
        {
            _listeners[index] = nil;
            break;
        }
    }
}

- (void)open
{
    HXSipCallback callback;
    callback.hxsip_on_account_state = hxsip_on_account_state;
    callback.hxsip_on_call_state = hxsip_on_call_state;
    HXSipClient_Open(callback);
}

- (void)close
{
    HXSipClient_Close();
}

- (void)makeCall:(NSString *)aUserId callId:(int *)aCallId
{
    HXSipClient_MakeCall((const char *)[aUserId UTF8String], aCallId);
}

- (void)answer:(NSInteger)aCallId 
{
    HXSipClient_Anwser(aCallId);
}

- (void)hangup:(NSInteger)aCallId
{
    HXSipClient_Hangup(aCallId,HXSipClientHangupDecline);
    
    [_autoUpdate invalidate];
    _autoUpdate = nil;
}

- (void)addAccount:(NSString *)aUserId
              name:(NSString *)aName
        department:(NSString *)aDepartment
{
 
    NSString *sendName = [NSString stringWithFormat:@"%@|%@", aName, aDepartment];
    HXSipClient_Register((const char*)[aUserId UTF8String],
                         (const char*)[sendName UTF8String]);
}

- (void)removeAccount:(NSString *)aUserId
{
    HXSipClient_Unregister((const char*)[aUserId UTF8String]);
}

- (void)startMeetingRequestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"responseString: %@", [request responseString]);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    id object = [parser objectWithString:[request responseString]];
    id status = [object objectForKey:@"status"];
    
    HXSipManagerStateInfo *stateInfo = [[[HXSipManagerStateInfo alloc] init] autorelease];
    
    if ([status isEqualToString:@"OK"])
    {
        stateInfo.code = HXSip_SC_OK;
        
        NSDictionary *info = [object objectForKey:@"info"];
        NSArray *warning = [info objectForKey:@"warning"];
        
        NSMutableString *warningStr = [NSMutableString stringWithCapacity:0];
        
        for (NSInteger index = 0; index < warning.count; ++index)
        {
            [warningStr appendFormat:@"%@\n", [warning objectAtIndex:index]];
        }
        if (warningStr.length)
        {
            stateInfo.warning = warningStr;
        }
    }
    else
    {
        stateInfo.warning = [object objectForKey:@"message"];
        stateInfo.code = HXSip_SC_BAD_REQUEST;
    }
    
    for (NSInteger index = 0; index < kListenerCount; ++index)
    {
        id<HXSipManagerDelegate> listener = [self delegateAtIndex:index];
        if ([listener respondsToSelector:@selector(hxSipManager:makeMeetingStateInfo:)])
        {            
            [listener hxSipManager:self makeMeetingStateInfo:stateInfo];
        }
    }
    
    [parser release];

}

- (void)startMeetingRequestFailed:(ASIHTTPRequest *)request
{
    HXSipManagerStateInfo *stateInfo = [[[HXSipManagerStateInfo alloc] init] autorelease];
    stateInfo.code = HXSip_SC_SERVICE_UNAVAILABLE;
    
    for (NSInteger index = 0; index < kListenerCount; ++index)
    {
        id<HXSipManagerDelegate> listener = [self delegateAtIndex:index];
        if ([listener respondsToSelector:@selector(hxSipManager:makeMeetingStateInfo:)])
        {
            [listener hxSipManager:self makeMeetingStateInfo:stateInfo];
        }
    }
}

- (void)startMeeting:(NSArray *)aMemberList
{
    static NSString *hostUrl = @"http://113.11.195.27:8080/conference";
    
    NSURL* url = [NSURL URLWithString:hostUrl];
	// Create a request
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setDidFailSelector:@selector(startMeetingRequestFailed:)];
    [request setDidFinishSelector:@selector(startMeetingRequestFinished:)];
    [request setPostValue:[aMemberList objectAtIndex:0] forKey:@"mediator"];
    
    for (int index = 1; index < aMemberList.count; ++index)
    {
        [request addPostValue:[aMemberList objectAtIndex:index]
                       forKey:@"part_in"];
    }
    [request setPostValue:@"" forKey:@"form.submitted"];
	// Start the request
	[request startAsynchronous];
}

#pragma mark - online member timer

- (void)startUpdateOnlimeMemberStatus
{
    if (_autoUpdate)
    {
        [_autoUpdate invalidate];
        _autoUpdate = nil;
    }
    
    [self updateOnlineMemberTimerAction];
    
    _autoUpdate = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                    target:self
                                                  selector:@selector(updateOnlineMemberTimerAction)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)stopUpdaleOnlineMemberStatus
{
    if (_autoUpdate)
    {
        [_autoUpdate invalidate];
        _autoUpdate = nil;
    }
}

//定时器回调
- (void)updateOnlineMemberTimerAction
{
    NSString *urlStr = @"http://113.11.195.27:8080/online";
    NSURL *onlineUrl = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:onlineUrl];
    [request setDidFinishSelector:@selector(updateOnlineRequestDidFinished:)];
    request.delegate = self;
    
    [request startAsynchronous];
}

- (void)updateOnlineMemberStatusWith:(NSDictionary *)memberInfos
{
    if (!memberInfos)
    {
        return;
    }
    
    HXSipMemberModel *memberModel = [HXSipMemberModel shareModel];
    
    for (NSInteger index = 0; index< [memberModel count];index++)
    {
        HXSipMember *localMemeber = [memberModel memberAtIndex:index];
 
        NSString *memeberId = [NSString stringWithFormat:@"%d", localMemeber.memberId];
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", memeberId];
        NSArray *search = [[memberInfos allKeys] filteredArrayUsingPredicate:resultPredicate];
        
        if ([search count] > 0)
        {
            localMemeber.isOnline = 1;
            
            //解析名字，部门字段
            NSString *userName = nil;
            NSString *userOrg = nil;
            
            NSDictionary *userInfo = [memberInfos objectForKey:memeberId];
            NSString *userDes = [userInfo objectForKey:@"Contact"];
            NSLog(@"===%@", userDes);
            NSArray *stringArray =  [userDes componentsSeparatedByString:@"\""];

            if ([stringArray count])
            {
                NSString *temStr = [stringArray objectAtIndex:1];
                NSArray *temArray =  [temStr componentsSeparatedByString:@"|"];
                if ([temArray count])
                {
                    userName = [temArray objectAtIndex:0];
                }
                
                if ([temArray count] >= 2)
                {
                    userOrg = [temArray objectAtIndex:1];
                }
            }
            
            localMemeber.name = userName;
            localMemeber.department = userOrg;
        }
        else
        {
            localMemeber.isOnline = 0;
        }
    }
}

- (void)updateOnlineRequestDidFinished:(ASIHTTPRequest *)aRequest
{
    NSString *responseStr = [[NSString alloc] initWithData:aRequest.responseData
                                                  encoding:NSUTF8StringEncoding];
    
    //NSLog(@"response str = %@", responseStr);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary *object = [parser objectWithString:responseStr];
    //NSLog(@"%d", [object count]);
    
    NSString *statusValue = [object objectForKey:@"status"];
    if (NSOrderedSame == [statusValue compare:@"OK" options:NSCaseInsensitiveSearch])
    {
        //NSLog(@"response OK");
        
        NSDictionary *infos = [object objectForKey:@"info"];
        
        [self updateOnlineMemberStatusWith:infos];
    }
    else
    {
        NSLog(@"response statuse:%@", statusValue);
    }
}

#pragma mark - room member timer

- (void)startUpdateMemberStatusInRoom:(NSString *)aRoomId
{
    if (_roomTimer)
    {
        [_roomTimer invalidate];
        _roomTimer = nil;
    }
    
    _roomTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                    target:self
                                                 selector:@selector(updateRoomMemberTimerAction:)
                                                  userInfo:aRoomId
                                                   repeats:YES];
    [self updateRoomMemberTimerAction:_roomTimer];
}

- (void)stopUpdateMemberStatusInRoom
{
    if (_roomTimer)
    {
        [_roomTimer invalidate];
        _roomTimer = nil;
    }
}

//会议室timer回调
- (void)updateRoomMemberTimerAction:(NSTimer *)aRoomTimer
{    
    NSString *urlStr = [NSString stringWithFormat:@"http://113.11.195.27:8080/conference/%@", (NSString *)aRoomTimer.userInfo];
    NSURL *onlineUrl = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:onlineUrl];
    [request setDidFinishSelector:@selector(updateRoomRequestDidFinished:)];
    request.delegate = self;
    
    [request startAsynchronous];
}

//更新会议室人员状态
- (void)updateRoomMemberStatusWith:(NSArray *)memberInfos
{
    if (!memberInfos)
    {
        return;
    }
    
    HXSipMemberModel *memberModel = [[HXSipMeetingMemberModel shareModel] memberModel];
    
    for (NSInteger index = 0; index < [memberInfos count]; ++index)
    {
        NSString *memberIdStr = [memberInfos objectAtIndex:index];
        HXSipMember *localMemeber = [memberModel memberWithMemberId:[memberIdStr integerValue]];
        
        if (localMemeber == nil)
        {
            HXSipMember *member = [[[HXSipMember alloc] init] autorelease];
            member.memberId = [memberIdStr integerValue];
            member.name = memberIdStr;
            member.isOnline = YES;
            member.department = @"和信勤丰";
        }
    }
    
    for (NSInteger index = 0; index< [memberModel count];index++)
    {
        HXSipMember *localMemeber = [memberModel memberAtIndex:index];
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", [NSString stringWithFormat:@"%d", localMemeber.memberId]];
        NSArray *search = [memberInfos filteredArrayUsingPredicate:resultPredicate];
        
        if ([search count] > 0)
        {
            localMemeber.status = 1;
            localMemeber.statusDescription = @"接通";
        }
        else
        {
            localMemeber.status = 0;
            localMemeber.statusDescription = @"未接通";
        }
    }
}

//获取会议室人员状态request回调
- (void)updateRoomRequestDidFinished:(ASIHTTPRequest *)aRequest
{
    NSString *responseStr = [[NSString alloc] initWithData:aRequest.responseData
                                                  encoding:NSUTF8StringEncoding];
    
    //NSLog(@"response str = %@", responseStr);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary *object = [parser objectWithString:responseStr];

    NSString *statusValue = [object objectForKey:@"status"];
    if (NSOrderedSame == [statusValue compare:@"OK" options:NSCaseInsensitiveSearch])
    {
        //NSLog(@"response OK");
        NSArray *infos = [object objectForKey:@"info"];
        [self updateRoomMemberStatusWith:infos];
    }
    else
    {
        NSLog(@"response statuse:%@", statusValue);
    }
}

@end
