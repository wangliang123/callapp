//
//  HXSipManager.h
//  HXSip
//
//  Created by Stupid on 12-10-29.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXSip.h"

typedef enum HXSip_status_code
{
    HXSip_SC_TRYING = 100,
    HXSip_SC_RINGING = 180,
    HXSip_SC_CALL_BEING_FORWARDED = 181,
    HXSip_SC_QUEUED = 182,
    HXSip_SC_PROGRESS = 183,
    
    HXSip_SC_OK = 200,
    HXSip_SC_ACCEPTED = 202,
    
    HXSip_SC_MULTIPLE_CHOICES = 300,
    HXSip_SC_MOVED_PERMANENTLY = 301,
    HXSip_SC_MOVED_TEMPORARILY = 302,
    HXSip_SC_USE_PROXY = 305,
    HXSip_SC_ALTERNATIVE_SERVICE = 380,
    
    HXSip_SC_BAD_REQUEST = 400,
    HXSip_SC_UNAUTHORIZED = 401,
    HXSip_SC_PAYMENT_REQUIRED = 402,
    HXSip_SC_FORBIDDEN = 403,
    HXSip_SC_NOT_FOUND = 404,
    HXSip_SC_METHOD_NOT_ALLOWED = 405,
    HXSip_SC_NOT_ACCEPTABLE = 406,
    HXSip_SC_PROXY_AUTHENTICATION_REQUIRED = 407,
    HXSip_SC_REQUEST_TIMEOUT = 408, //连接超时
    HXSip_SC_GONE = 410,
    HXSip_SC_REQUEST_ENTITY_TOO_LARGE = 413,
    HXSip_SC_REQUEST_URI_TOO_LONG = 414,
    HXSip_SC_UNSUPPORTED_MEDIA_TYPE = 415,
    HXSip_SC_UNSUPPORTED_URI_SCHEME = 416,
    HXSip_SC_BAD_EXTENSION = 420,
    HXSip_SC_EXTENSION_REQUIRED = 421,
    HXSip_SC_SESSION_TIMER_TOO_SMALL = 422,
    HXSip_SC_INTERVAL_TOO_BRIEF = 423,
    HXSip_SC_TEMPORARILY_UNAVAILABLE = 480,
    HXSip_SC_CALL_TSX_DOES_NOT_EXIST = 481,
    HXSip_SC_LOOP_DETECTED = 482,
    HXSip_SC_TOO_MANY_HOPS = 483,
    HXSip_SC_ADDRESS_INCOMPLETE = 484,
    HXSip_AC_AMBIGUOUS = 485,
    HXSip_SC_BUSY_HERE = 486,
    HXSip_SC_REQUEST_TERMINATED = 487,
    HXSip_SC_NOT_ACCEPTABLE_HERE = 488,
    HXSip_SC_BAD_EVENT = 489,
    HXSip_SC_REQUEST_UPDATED = 490,
    HXSip_SC_REQUEST_PENDING = 491,
    HXSip_SC_UNDECIPHERABLE = 493,
    
    HXSip_SC_INTERNAL_SERVER_ERROR = 500,
    HXSip_SC_NOT_IMPLEMENTED = 501,
    HXSip_SC_BAD_GATEWAY = 502,
    HXSip_SC_SERVICE_UNAVAILABLE = 503,
    HXSip_SC_SERVER_TIMEOUT = 504,
    HXSip_SC_VERSION_NOT_SUPPORTED = 505,
    HXSip_SC_MESSAGE_TOO_LARGE = 513,
    HXSip_SC_PRECONDITION_FAILURE = 580,
    
    HXSip_SC_BUSY_EVERYWHERE = 600,
    HXSip_SC_DECLINE = 603,  //A呼叫B,A主动挂断时会报这个error
    HXSip_SC_DOES_NOT_EXIST_ANYWHERE = 604,
    HXSip_SC_NOT_ACCEPTABLE_ANYWHERE = 606,
    
    HXSip_SC_TSX_TIMEOUT = HXSip_SC_REQUEST_TIMEOUT,
    /*PJSIP_SC_TSX_RESOLVE_ERROR = 702,*/
    HXSip_SC_TSX_TRANSPORT_ERROR = HXSip_SC_SERVICE_UNAVAILABLE,
    
    /* This is not an actual status code, but rather a constant
     * to force GCC to use 32bit to represent this enum, since
     * we have a code in PJSUA-LIB that assigns an integer
     * to this enum (see pjsua_acc_get_info() function).
     */
    HXSip_SC__force_32bit = 0x7FFFFFFF
}HXSip_status_code;

@interface HXSipManagerStateInfo : NSObject

@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, retain) NSString *warning;
@property (nonatomic, retain) NSString *removeInfo;

@end

@class HXSipManager;

@protocol HXSipManagerDelegate <NSObject>

@optional

- (void) hxSipManager:(HXSipManager *) aSipManager
     accountStateInfo:(HXSipManagerStateInfo *) aStateInfo;

- (void) hxSipManager:(HXSipManager *) aSipManager
               callId:(NSInteger)aCallId
        callStateInfo:(HXSipManagerStateInfo *) aStateInfo;

- (void) hxSipManager:(HXSipManager *)aSipManager
 makeMeetingStateInfo:(HXSipManagerStateInfo *)aStateInfo;

@end

@interface HXSipManagerMemo : NSObject

@property (nonatomic, assign) NSInteger callId;
@property (nonatomic, assign) NSInteger accoundId;
@property (nonatomic, assign) NSInteger roomId;

@end

#define kListenerCount 10

@interface HXSipManager : NSObject
{
    NSTimer *_autoUpdate;
    NSTimer *_roomTimer;
    id<HXSipManagerDelegate> _listeners[kListenerCount];
}

+ (HXSipManager *)shareManager;

- (HXSipManagerMemo *)memo;

- (void)addListener:(id<HXSipManagerDelegate>)aListener;
- (void)removeListener:(id<HXSipManagerDelegate>)aListener;

- (void)open;
- (void)close;

- (void)makeCall:(NSString *)aUserId callId:(int *)aCallId;
- (void)answer:(NSInteger)aCallId;
- (void)hangup:(NSInteger)aCallId;
- (void)addAccount:(NSString *)aUserId
              name:(NSString *)aName
        department:(NSString *)aDepartment;
- (void)removeAccount:(NSString *)aUserId;

// Id 列表, 第一项为发起者
- (void)startMeeting:(NSArray *)aMemberList;

// 轮询获取在线人员状态
- (void)startUpdateOnlimeMemberStatus;
- (void)stopUpdaleOnlineMemberStatus;

// 轮询获取房间人员状态
- (void)startUpdateMemberStatusInRoom:(NSString *)aRoomId;
- (void)stopUpdateMemberStatusInRoom;

@end
