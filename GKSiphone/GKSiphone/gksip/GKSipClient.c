//
//  GKSipClient.c
//  GKSip
//
//  Created by Stupid on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipClient.h"

#include <pjlib.h>
#include "GKSipUa.h"
#include "GKSipSetting.h"
#include "GKSipPool.h"
#include "GKSipAccount.h"
#include "GKSipCall.h"


typedef struct GKSipClientCmd GKSipClientCmd;

struct GKSipClientImp
{
    GKSipCallback callback;
};

typedef struct GKSipClientImp GKSipClientImp;

static GKSipClientImp* GKClientImp = NULL;

static SipCallEvent _sipCallEvent = NULL;

static void on_GKsip_call_state_bc(pjsua_call_id aCall_Id,
                                   GKSipCallState state,
                                   pjsip_status_code status_code,
                                   pj_str_t *remote_info)
{
    if (GKClientImp &&
        GKClientImp->callback.GKsip_on_call_state)
    {
        
        GKSipClientStateInfo stateInfo;
        stateInfo.code = status_code;
        stateInfo.state = state;
        memset(stateInfo.info, 0, 256);
        strncpy(stateInfo.info, pj_strbuf(remote_info), pj_strlen(remote_info));
        
        GKClientImp->callback.GKsip_on_call_state(aCall_Id, &stateInfo);
    }
}

static void on_GKsip_account_state_bc(GKSipAccountState state,
                                      int status_code)
{
    if (GKClientImp &&
        GKClientImp->callback.GKsip_on_account_state)
    {
        GKSipClientStateInfo stateInfo;
        stateInfo.code = status_code;
        stateInfo.state = state;
        
        GKClientImp->callback.GKsip_on_account_state(&stateInfo);
    }
}

/* Private Methods */
static GKSipClientImp* defaultSipClientImp(GKSipCallback callback)
{
    if (GKClientImp == NULL)
    {
        GKClientImp = (GKSipClientImp *)malloc(sizeof(GKSipClientImp));
        GKClientImp->callback = callback;
        
        if (GKSipUa_open() == PJ_SUCCESS)
        {
            GKSip_call_set_callback(on_GKsip_call_state_bc);
            GKSip_account_set_callback(on_GKsip_account_state_bc);
        }
        else
        {
            free(GKClientImp);
            GKClientImp = NULL;
        }
    }
    return GKClientImp;
}

/* Public Methods */
GK_DEF(GKsip_status_t) GKSipClient_Open(GKSipCallback callback)
{
    if (defaultSipClientImp(callback))
        return GKSIP_SUCCESS;
    return GKSIP_FAIL;
}

GK_DEF(GKsip_status_t) GKSipClient_Close(void)
{
    if (GKClientImp)
    {
        GKSip_setting_close();
        GKSipUa_close();
        
        GKSip_global_pool_destroy();
        
        free(GKClientImp);
        GKClientImp = NULL;
    }
    
    return GKSIP_SUCCESS;
}

GK_DEF(GKsip_status_t) GKSipClient_SetBackgroundMode(int aBackgroundMode)
{
    if (aBackgroundMode)
    {
        GKSip_account_set_timeout(600);
    }
    else
    {
        GKSip_account_set_timeout(60);
    }
    return GKSIP_SUCCESS;
}

GK_DEF(GKsip_status_t) GKSipClient_LoadSetting(const char *aData,
                                               size_t aLen)
{
    GKSip_setting_load(GKSip_default_pool(),
                       (char *)aData,
                       (pj_size_t)aLen);
    
    return GKSIP_SUCCESS;
}

GK_DEF(GKsip_status_t) GKSipClient_Register(const char *aUser,
                                             const char *aUserName,
                                             const char *aPassword,
                                             const char *aSip_server,
                                             const int sip_server_port)
{
    GKSip_account_register(aUser,
                           aUserName,
                           aPassword,
                           aSip_server,
                           sip_server_port);
    
    return GKSIP_SUCCESS;
}

GK_DEF(GKsip_status_t) GKSipClient_Unregister(const char *aUserId)
{
    PJ_UNUSED_ARG(aUserId);
    GKSip_account_unregister();
    
    return GKSIP_SUCCESS;
}

GK_DEF(GKsip_status_t) GKSipClient_MakeCall(const char *aUserId,
                                            int *aCallId)
{
    pj_str_t sipUrl = GKSip_get_sip_url(aUserId);
    pj_status_t status = GKSip_call_make_call(sipUrl, aCallId);
    free(sipUrl.ptr);
    
    return status;
}

GK_DEF(GKsip_status_t) GKSipClient_Anwser(int aCallId)
{
    return GKSip_call_anwser(aCallId);
}

GK_DEF(GKsip_status_t) GKSipClient_Hangup(int aCallId,
                                          GKSipClientHangupType aHangupType)
{
    if (aHangupType == GKSipClientHangupDecline)
        return GKSip_call_hangup(aCallId);

    return GKSip_call_busy(aCallId);
}


void GKSipClient_SetSipCallEvent(SipCallEvent e)
{
    _sipCallEvent = e;
}

/*
 * 触发sip呼叫事件
 */
void GKSipClient_PostSipCallEvent(pjsua_call_info* call_info)
{
    if (_sipCallEvent)
        _sipCallEvent(call_info);
}