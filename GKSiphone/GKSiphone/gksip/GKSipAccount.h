//
//  GKSipAccount.h
//  GKSip
//
//  Created by zhengjian on 12-9-10.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPACCOUNT_H__
#define __GKSIPACCOUNT_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

/**
 关于pj_str_t的说明!!
 
 pj_str_t中有两个字段: 首地址指针和字符串长度
 需要主要两点:
 1) 字符串是非'\0'结尾的.
 2) 设置字符串的时候, 内部实现是assgin操作, 内存处理需要使用者去实现
 如: 
 
 PJ_IDEF(pj_str_t) pj_str(char *str)
 {
     pj_str_t dst;
     dst.ptr = str;
     dst.slen = str ? pj_ansi_strlen(str) : 0;
     return dst;
 }
 */

typedef struct GKSipAccount {
    pj_str_t sip_server;
    pj_str_t user;
    pj_str_t password;
    
    int sip_server_port;
    
    pjsua_acc_id account_id;    // 注册成功后的ID
} GKSipAccount;


typedef enum GKSipAccountState {
    GKSipAccountStateOnline,       // 账号成功注册
    GKSipAccountStateInProcess,     // 账号正在注册中
    GKSipAccountStateOffline,      // 没有账号注册
    GKSipAccountStateUnknown
} GKSipAccountState;

/*
 客户端的响应账号状态变化的回调函数
 */
typedef void (*GKSip_account_state_bc)(GKSipAccountState state, int status_code);

/*
 创建账号对象, 由GKSipUa维护
 */
PJ_DECL(void) GKSip_account_create(void);

/*
 删除账号对象, 由GKSipUa维护
 */
PJ_DECL(void) GKSip_account_release(void);

/*
 SIP账号注册。
 PJSIP使用的是异步机制，无法从返回值中判断当前是否注册成功，而是从触发的SIP消息中。
 因此，需要保存当前的账号状态，每当触发SIP状态改变的消息时，同步更新账号状态。
 在实现中，用一个静态局部变量，保存当前注册的账号信息。
 */
PJ_DECL(void) GKSip_account_register(const char *user,
                                     const char *userName,
                                     const char *password,
                                     const char *sip_server,
                                     const int sip_server_port);

/*
 SIP账号注销
 */
PJ_DECL(void) GKSip_account_unregister(void);

/*
 返回当前注册的账号的详细情况。
 */
PJ_DECL(const GKSipAccount *) GKSip_account_get(void);


/*
 设置失效时间.
 */
PJ_DECL(void) GKSip_account_set_timeout(int aTimeOut);

/*
 根据当前注册账号的SIP服务器，生成完整的SIP URL。
 如，当前注册到sip.bafangbang.com时，传入参数：1001，返回: sip:1001@sip.bafangbang.com
 */
PJ_DECL(pj_str_t) GKSip_get_sip_url(const char *user);

/*
 检测当前账号状态
 */
PJ_DECL(GKSipAccountState) GKSip_account_get_status(void);

/*
 设置账号状态改变时的回调函数
 */
PJ_DECL(void) GKSip_account_set_callback(GKSip_account_state_bc callback);

/**
 * PJSIP的相应函数, 客户端不需要处理此处回调
 */
PJ_DECL(void) GKSip_account_set_pj_callback(pjsua_callback *callback);

PJ_END_DECL


#endif
