//
//  GKSipClient.h
//  GKSip
//
//  Created by 赵国刚 on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

/**
* GKSip应用层, 提供Sip服务访问接口, 客户端只需要与此接口交互即可
*/

#ifndef __GKSIPCLIENT_H__
#define __GKSIPCLIENT_H__

#if !defined(GK_DECL)
#   if defined(__cplusplus)
#	define GK_DECL(type)	    type
#   else
#	define GK_DECL(type)	    extern type
#   endif
#endif

#ifndef GK_EXPORT_DEF_SPECIFIER
#   define GK_EXPORT_DEF_SPECIFIER
#endif

#if defined(GK_DLL) && defined(GK_EXPORTING)
#   define GK_DEF(type)		    GK_EXPORT_DEF_SPECIFIER type
#elif !defined(GK_DEF)
#   define GK_DEF(type)		    type
#endif


#define kAccountIdLength 30

#include <stdio.h>
#include "GKSipClientState.h"

typedef int		GKsip_status_t;

#include <pjsua-lib/pjsua.h>


/** Status is OK. */
#define GKSIP_SUCCESS  0

#define GKSIP_FAIL -1

typedef enum GKSip_status_code
{
    GKSip_SC_TRYING = 100,
    GKSip_SC_RINGING = 180,
    GKSip_SC_CALL_BEING_FORWARDED = 181,
    GKSip_SC_QUEUED = 182,
    GKSip_SC_PROGRESS = 183,
    
    GKSip_SC_OK = 200,
    GKSip_SC_ACCEPTED = 202,
    
    GKSip_SC_MULTIPLE_CHOICES = 300,
    GKSip_SC_MOVED_PERMANENTLY = 301,
    GKSip_SC_MOVED_TEMPORARILY = 302,
    GKSip_SC_USE_PROXY = 305,
    GKSip_SC_ALTERNATIVE_SERVICE = 380,
    
    GKSip_SC_BAD_REQUEST = 400,
    GKSip_SC_UNAUTHORIZED = 401,
    GKSip_SC_PAYMENT_REQUIRED = 402,
    GKSip_SC_FORBIDDEN = 403,
    GKSip_SC_NOT_FOUND = 404,
    GKSip_SC_METHOD_NOT_ALLOWED = 405,
    GKSip_SC_NOT_ACCEPTABLE = 406,
    GKSip_SC_PROXY_AUTHENTICATION_REQUIRED = 407,
    GKSip_SC_REQUEST_TIMEOUT = 408, //连接超时
    GKSip_SC_GONE = 410,
    GKSip_SC_REQUEST_ENTITY_TOO_LARGE = 413,
    GKSip_SC_REQUEST_URI_TOO_LONG = 414,
    GKSip_SC_UNSUPPORTED_MEDIA_TYPE = 415,
    GKSip_SC_UNSUPPORTED_URI_SCHEME = 416,
    GKSip_SC_BAD_EXTENSION = 420,
    GKSip_SC_EXTENSION_REQUIRED = 421,
    GKSip_SC_SESSION_TIMER_TOO_SMALL = 422,
    GKSip_SC_INTERVAL_TOO_BRIEF = 423,
    GKSip_SC_TEMPORARILY_UNAVAILABLE = 480,
    GKSip_SC_CALL_TSX_DOES_NOT_EXIST = 481,
    GKSip_SC_LOOP_DETECTED = 482,
    GKSip_SC_TOO_MANY_HOPS = 483,
    GKSip_SC_ADDRESS_INCOMPLETE = 484,
    GKSip_AC_AMBIGUOUS = 485,
    GKSip_SC_BUSY_HERE = 486,
    GKSip_SC_REQUEST_TERMINATED = 487,
    GKSip_SC_NOT_ACCEPTABLE_HERE = 488,
    GKSip_SC_BAD_EVENT = 489,
    GKSip_SC_REQUEST_UPDATED = 490,
    GKSip_SC_REQUEST_PENDING = 491,
    GKSip_SC_UNDECIPHERABLE = 493,
    
    GKSip_SC_INTERNAL_SERVER_ERROR = 500,
    GKSip_SC_NOT_IMPLEMENTED = 501,
    GKSip_SC_BAD_GATEWAY = 502,
    GKSip_SC_SERVICE_UNAVAILABLE = 503,
    GKSip_SC_SERVER_TIMEOUT = 504,
    GKSip_SC_VERSION_NOT_SUPPORTED = 505,
    GKSip_SC_MESSAGE_TOO_LARGE = 513,
    GKSip_SC_PRECONDITION_FAILURE = 580,
    
    GKSip_SC_BUSY_EVERYWHERE = 600,
    GKSip_SC_DECLINE = 603,  //A呼叫B,A主动挂断时会报这个error
    GKSip_SC_DOES_NOT_EXIST_ANYWHERE = 604,
    GKSip_SC_NOT_ACCEPTABLE_ANYWHERE = 606,
    
    GKSip_SC_TSX_TIMEOUT = GKSip_SC_REQUEST_TIMEOUT,
    /*PJSIP_SC_TSX_RESOLVE_ERROR = 702,*/
    GKSip_SC_TSX_TRANSPORT_ERROR = GKSip_SC_SERVICE_UNAVAILABLE,
    
    /* This is not an actual status code, but rather a constant
     * to force GCC to use 32bit to represent this enum, since
     * we have a code in PJSUA-LIB that assigns an integer
     * to this enum (see pjsua_acc_get_info() function).
     */
    GKSip_SC__force_32bit = 0x7FFFFFFF
}GKSip_status_code;


#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct GKSipClientStateInfo
{
    int state;
    int code;
    char info[256];
} GKSipClientStateInfo;

typedef struct GKSipCallback
{
    // 账户状态, 注册/注销执行状态
    void (*GKsip_on_account_state)(const GKSipClientStateInfo* aStateInfo);
    // Call相关的状态
    void (*GKsip_on_call_state)(const int call_id,
                                const GKSipClientStateInfo* aStateInfo);
} GKSipCallback;
    
typedef enum GKSipClientHangupType
{
    GKSipClientHangupDecline,
    GKSipClientHangupBusy
} GKSipClientHangupType;

/**
* 构造函数.
* 构造基本成员, 启动pjsipua
*
* @return GKSIP_SUCCESS表示成功, 其他值表示失败.
*/
GK_DECL(GKsip_status_t) GKSipClient_Open(GKSipCallback callback);
    
/**
* 析构函数.
* 终止线程, 清空全部内存.
*
* @return GKSIP_SUCCESS表示成功, 其他值表示失败.
*/
GK_DECL(GKsip_status_t) GKSipClient_Close(void);
    
/**
 * 设置后台模式.
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败.
 */
GK_DECL(GKsip_status_t) GKSipClient_SetBackgroundMode(int aBackgroundMode);
    
/**
* 加载XML配置文件.
* 
* @param aData xml字符串.
* @param aLen xml字符串长度.
*
* @return GKSIP_SUCCESS表示成功, 其他值表示失败.
*/
GK_DECL(GKsip_status_t) GKSipClient_LoadSetting(const char *aData,
                                                size_t aLen);

/**
 * 注册用户.
 *
 * @param aUserId 用户ID 例如: 1001.
 * @param aUserName 用户名 例如: hexinqinfeng.
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败..
 */
GK_DECL(GKsip_status_t) GKSipClient_Register(const char *aUser,
                                            const char *aUserName,
                                            const char *aPassword,
                                            const char *aSip_server,
                                            const int sip_server_port);

/**
 * 注销用户.
 *
 * @param aUserId 用户ID 例如: 1001.
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败..
 */
GK_DECL(GKsip_status_t) GKSipClient_Unregister(const char *aUserId);

/**
 * 拨打电话.
 *
 * @param aUserId 用户ID 例如: 1001.
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败..
 */
GK_DECL(GKsip_status_t) GKSipClient_MakeCall(const char *aUserId,
                                             int *aCallId);
    
/**
 * 接听电话.
 *
 * @param aCallId Call ID.
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败..
 */
GK_DECL(GKsip_status_t) GKSipClient_Anwser(int aCallId);
    
/**
 * 挂断电话.
 *
 * @param aCallId Call ID.
 * @param aHangupType 挂断方式(挂断/用户忙)
 *
 * @return GKSIP_SUCCESS表示成功, 其他值表示失败..
 */
GK_DECL(GKsip_status_t) GKSipClient_Hangup(int aCallId,
                                           GKSipClientHangupType aHangupType);



typedef void (*SipCallEvent)(pjsua_call_info*);
    
/*
 * 当pjsip的sip呼叫事件的响应
 */
void GKSipClient_SetSipCallEvent(SipCallEvent e);

/*
 * 触发sip呼叫事件
 */
void GKSipClient_PostSipEvent(pjsua_call_info* call_info);
    
#ifdef __cplusplus
};
#endif

#endif
