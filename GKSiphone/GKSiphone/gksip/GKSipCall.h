//
//  GKSipCall.h
//  GKSip
//
//  Created by Stupid on 12-8-29.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPCALLHANDLER_H_
#define __GKSIPCALLHANDLER_H_

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

typedef enum GKSipCallState {
    GKSipCallStateCalling,
    GKSipCallStateIncoming,
    GKSipCallStateConnecting,
    GKSipCallStateConfirmed,
    GKSipCallStateDisconnected
} GKSipCallState;

/*
 * 客户端的响应账号状态变化的回调函数
 */
typedef void (*GKSip_call_state_bc)(pjsua_call_id aCall_Id,
                                    GKSipCallState state,
                                    pjsip_status_code status_code,
                                    pj_str_t *remote_info);

/**
 * 创建Call实例, 并且初始化, 内部实现为单例模式.
 *
 * @param config 用于创建ringtone.
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_create(const pjsua_media_config *config);

/**
 * 析构Call实例.
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_release(void);

/**
 * 拨打电话
 *
 * @param aUserId 用户ID 例如: 1001.
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_make_call(pj_str_t aUserId,
                                          pjsua_call_id *aCall_Id);

/**
 * 接听电话
 *  
 * @param aUserId 用户ID 例如: 1001.
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_anwser(pjsua_call_id aCall_Id);

/**
 * 挂断当前的电话
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_hangup(pjsua_call_id aCall_Id);

/**
 * 挂断当前的电话, 当前用户忙
 *
 * @return PJ_SUCCESS on success, or the appropriate error code.
 */
PJ_DECL(pj_status_t) GKSip_call_busy(pjsua_call_id aCall_Id);

/**
 * 设置回调函数
 *
 * @param GKSip_call_state_bc 回调函数.
 */
PJ_DECL(void) GKSip_call_set_callback(GKSip_call_state_bc callback);

/**
 * PJSIP的相应函数, 客户端不需要处理此处回调
 */
PJ_DECL(void) GKSip_call_set_pj_callback(pjsua_callback *callback);

PJ_END_DECL

#endif
