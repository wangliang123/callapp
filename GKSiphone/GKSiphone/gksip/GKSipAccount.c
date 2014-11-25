
//
//  GKSipAccount.c
//  GKSip
//
//  Created by Stupid on 12-9-13.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipAccount.h"
#include "GKSipUa.h"

#define PJ_STR_CLEAR(STR) if (STR.ptr) { free(STR.ptr); STR.ptr = NULL; }

//#define kREG_URL "sip:113.11.195.27:6060"
//#define kREALM "113.11.195.27"
//#define kID_FORMAT "%s <sip:%s@113.11.195.27:6060>"
//#define kID_FORMAT2 "sip:%s@113.11.195.27:6060"

/*
 每60秒重新注册
 */
#define REGISTER_INTERVAL_SECOND 60

#define INTERNAL_POOL_SIZE 1024

typedef struct GKSipAccountMgr
{
    GKSipAccountState state;
    GKSipAccount account;
    GKSip_account_state_bc callback;
    char sipHost[256];
    int  sipPort;
} GKSipAccountMgr;

static GKSipAccountMgr *accountMgr = NULL;

// Private Methods
static void notify(int status_code)
{
    if (accountMgr && accountMgr->callback)
    {
        accountMgr->callback(accountMgr->state, status_code);
    }
}

static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info)
{
    if (accountMgr)
    {
        if (accountMgr->account.account_id == acc_id &&
            info->cbparam->status == PJ_SUCCESS &&
            info->cbparam->code == PJSIP_SC_OK)
        {
            
            accountMgr->state = GKSipAccountStateOnline;
        }
        else
        {
            accountMgr->state = GKSipAccountStateOffline;
        }
        
        notify(info->cbparam->code);
        
        
//        char buf[80];
//        pjsua_acc_info info;
//        
//        pjsua_acc_get_info(login_user.account_id, &info);
//        
//        pj_ansi_snprintf(buf,
//                         sizeof(buf),
//                         "%d/%.*s (expires=%d)",
//                         info.status,
//                         (int)info.status_text.slen,
//                         info.status_text.ptr,
//                         info.expires);
//        
//        printf(" [%2d] %.*s: %s\n",
//               login_user.account_id,
//               (int)info.acc_uri.slen,
//               info.acc_uri.ptr,
//               buf);
    }
}

static void pj_set_str(pj_str_t *aPj_str, const char *aCStr)
{
    char *str = (char *)malloc(strlen(aCStr)*sizeof(char) + 1);
    memset(str, 0, strlen(aCStr) + 1);
    memcpy(str, aCStr, strlen(aCStr));
    *aPj_str = pj_str(str);
}

PJ_DEF(void) GKSip_account_create(void)
{
    if (accountMgr == NULL)
    {
        accountMgr = (GKSipAccountMgr *)malloc(sizeof(GKSipAccountMgr));
        memset(accountMgr, 0, sizeof(GKSipAccountMgr));
        
        accountMgr->state = GKSipAccountStateOffline;
        accountMgr->account.account_id = PJSUA_INVALID_ID;
        accountMgr->callback = NULL;
    }
}

PJ_DEF(void) GKSip_account_release(void)
{
    if (accountMgr)
    {
        PJ_STR_CLEAR(accountMgr->account.user);
        PJ_STR_CLEAR(accountMgr->account.password);
        PJ_STR_CLEAR(accountMgr->account.sip_server);
        
        free(accountMgr);
        accountMgr = NULL;
    }
}


PJ_DEF(void) GKSip_account_register(const char *aUser,
                                    const char *aUserName,
                                    const char *aPassword,
                                    const char *aSip_server,
                                    const int sip_server_port)
{

    if (accountMgr && accountMgr->state != GKSipAccountStateInProcess)
    {
        
        PJ_STR_CLEAR(accountMgr->account.user);
        pj_set_str(&accountMgr->account.user, aUser);
        
        PJ_STR_CLEAR(accountMgr->account.password);
        pj_set_str(&accountMgr->account.password, aPassword);
        
        PJ_STR_CLEAR(accountMgr->account.sip_server);
        
        memset(accountMgr->sipHost, 0, 256);
        strcpy(accountMgr->sipHost, aSip_server);
        
        accountMgr->sipPort = sip_server_port;
        
        char idStr[256];
        memset(idStr, 0, sizeof(idStr));
        sprintf(idStr, "%s <sip:%s@%s:%d>", aUserName, aUser, accountMgr->sipHost, accountMgr->sipPort);
        pj_set_str(&accountMgr->account.sip_server, idStr);
        
        accountMgr->account.sip_server_port = sip_server_port;
        
        pjsua_acc_config acc_cfg;
        pj_status_t status;
        pjsua_acc_config_default(&acc_cfg);
        pj_status_t pjsip_auth_clt_init_req(pjsip_auth_clt_sess *sess,pjsip_tx_data *TDATA  );
        
        acc_cfg.id = accountMgr->account.sip_server;
        char regUrl[256];
        memset(regUrl, 0, 256);
        sprintf(regUrl, "sip:%s:%d", accountMgr->sipHost, accountMgr->sipPort);
        acc_cfg.reg_uri = pj_str(regUrl);
        acc_cfg.cred_count = 1;
        acc_cfg.cred_info[0].scheme = pj_str("Digest");
        acc_cfg.cred_info[0].realm = pj_str("asterisk");
        acc_cfg.cred_info[0].username = accountMgr->account.user;
        acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        acc_cfg.cred_info[0].data = accountMgr->account.password;

//        char proxy[256];
//        memset(proxy, 0, 256);
//        sprintf(proxy, "sip:%s;transport=tcp",aSip_server);
//        acc_cfg.proxy[acc_cfg.proxy_cnt++] = pj_str(proxy);
        
        acc_cfg.rtp_cfg = *GKSipUa_udp_cfg();
        acc_cfg.reg_timeout = REGISTER_INTERVAL_SECOND;
        
        pjsua_acc_id acc_id;
        status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &acc_id);
        
        if (status !=PJ_SUCCESS) {
            
        }
        if (status == PJ_SUCCESS)
        {
            accountMgr->account.account_id = acc_id;
            accountMgr->state = GKSipAccountStateInProcess;
            notify(PJSIP_SC_OK);
        }
    }

    
}

PJ_DEF(void) GKSip_account_unregister(void)
{
    if (accountMgr && accountMgr->state != GKSipAccountStateInProcess)
    {
        pjsua_acc_id acc_id = accountMgr->account.account_id;
        if (pjsua_acc_is_valid(acc_id))
        {
            if (pjsua_acc_del(acc_id) == PJ_SUCCESS)
            {
                accountMgr->state = GKSipAccountStateOffline;
                accountMgr->account.account_id = PJSUA_INVALID_ID;
                notify(PJSIP_SC_OK);
            }
        }
    }
}

PJ_DEF(const GKSipAccount *) GKSip_account_get(void)
{
    if (accountMgr)
        return &accountMgr->account;
    return NULL;
}

PJ_DEF(void) GKSip_account_set_timeout(int aTimeOut)
{
    if (accountMgr)
    {
        pjsua_acc_config acc_cfg;
        pj_status_t status = pjsua_acc_get_config(accountMgr->account.account_id,
                                                  &acc_cfg);
        if (status == PJ_SUCCESS)
        {
            acc_cfg.reg_timeout = aTimeOut;
            pjsua_acc_set_registration(accountMgr->account.account_id, PJ_TRUE);
            
        }
    }
}

PJ_DEF(GKSipAccountState) GKSip_account_get_status(void)
{
    if (accountMgr)
        return accountMgr->state;
    return GKSipAccountStateUnknown;
}

PJ_DEF(pj_str_t) GKSip_get_sip_url(const char *user)
{
    pj_str_t ret;
    if (accountMgr)
    {
        char idStr[256];
        memset(idStr, 0, sizeof(idStr));
        sprintf(idStr, "sip:%s@%s:%d", user, accountMgr->sipHost, accountMgr->sipPort);
        pj_set_str(&ret, idStr);
    }
    return ret;
}

PJ_DEF(void) GKSip_account_set_callback(GKSip_account_state_bc callback)
{
    if (accountMgr)
        accountMgr->callback = callback;
}

PJ_DEF(void) GKSip_account_set_pj_callback(pjsua_callback *callback)
{
    callback->on_reg_state2 = &on_reg_state2;
    callback->on_reg_started = NULL;
}