//
//  GKSipUa.c
//  
//
//  Created by Stupid on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipUa.h"

#include "GKSipModule.h"
#include "GKSipCall.h"
#include "GKSipAccount.h"
#include "GKSipConfig.h"

#define THIS_FILE	"GKSipUa.c"


static int initialized;

static void set_sip_agent(pj_str_t* agent);
static pj_status_t create_udp(pjsua_transport_config *config);
static pj_status_t create_tcp(pjsua_transport_config *config);
static void set_media_codecs(void);

PJ_DEF(pj_status_t) GKSipUa_open(void)
{
    if (initialized > 0)
        return PJ_SUCCESS;
    
    pj_status_t status;
    
    /* Create pjsua */
    status = pjsua_create();
    if (status != PJ_SUCCESS)
        return status;
    
    /* Create pool for application */
    gkSipConfig.pool = pjsua_pool_create("GKsip", 1000, 1000);
    
    
    gkSipConfig.cfg = get_pjsua_config();
    gkSipConfig.log_cfg = get_log_config();
    gkSipConfig.media_cfg = get_media_config();
    gkSipConfig.udp_cfg = get_udp_config();
    gkSipConfig.rtp_cfg = get_rtp_config();
    gkSipConfig.redir_op = PJSIP_REDIRECT_ACCEPT;
    
    GKSip_account_create();
    GKSip_account_set_pj_callback(&gkSipConfig.cfg.cb);
    GKSip_call_set_pj_callback(&gkSipConfig.cfg.cb);
    
        /* Initialize pjsua */
    status = pjsua_init(&gkSipConfig.cfg,
                        &gkSipConfig.log_cfg,
                        &gkSipConfig.media_cfg);
    if (status != PJ_SUCCESS)
        goto on_error;
    
    /* Initialize our module to handle otherwise unhandled request */
    status = pjsip_endpt_register_module(pjsua_get_pjsip_endpt(),
                                         GKSip_default_module());
    
    if (status != PJ_SUCCESS)
        goto on_error;
    
    /* Initialize calls data */
    status = GKSip_call_create(&gkSipConfig.media_cfg);
    if (status != PJ_SUCCESS) goto on_error;
    
    status = create_udp(&gkSipConfig.udp_cfg);
    if (status != PJ_SUCCESS) goto on_error;
    
//    status = create_tcp(&gkSipConfig.udp_cfg);
//    if (status != PJ_SUCCESS) goto on_error;
//
    set_media_codecs();
    
    status = pjsua_start();
    
    if (status != PJ_SUCCESS)
        goto on_error;
    
    ++initialized;
    
    return status;

    on_error:
    GKSipUa_close();
    return status;
}

PJ_DEF(pj_status_t) GKSipUa_close(void)
{
    if (--initialized > 0)
        return PJ_SUCCESS;
    
    pj_status_t status;
    
    GKSip_call_release();
    GKSip_account_release();
    
    if (gkSipConfig.pool)
    {
        pj_pool_release(gkSipConfig.pool);
        gkSipConfig.pool = NULL;
    }
    
    status = pjsua_destroy();
    pj_bzero(&gkSipConfig, sizeof(gkSipConfig));
    
    return status;
}

PJ_DEF(pjsua_transport_config *) GKSipUa_udp_cfg(void)
{
    return  &gkSipConfig.udp_cfg;
}

PJ_DEF(pjsua_transport_config *) GKSipUa_rtp_cfg(void)
{
    return  &gkSipConfig.rtp_cfg;
}

// 设置语音编码，将ILIBC设为首选
static void set_media_codecs(void)
{
    pj_str_t ilbc_id;
    
    ilbc_id = pj_str("iLBC/8000/1");
    
    if (pjsua_codec_set_priority(&ilbc_id, PJMEDIA_CODEC_PRIO_HIGHEST) != PJ_SUCCESS)
        PJ_LOG(3, (THIS_FILE, "Set Codecs(%.s) priority failed.", ilbc_id.slen, ilbc_id.ptr));
    else
        PJ_LOG(3, (THIS_FILE, "Set Codecs(%.s) priority to highest", ilbc_id.slen, ilbc_id.ptr));
}



static pj_status_t _create_network(pjsua_transport_config *config, pjsip_transport_type_e type)
{
//    PJ_DECL(pj_status_t) pjsua_transport_create(pjsip_transport_type_e type,
//                                                const pjsua_transport_config *cfg,
//                                                pjsua_transport_id *p_id);
    pj_status_t status;
    
    pjsua_transport_id transport_id = -1;
    
    status = pjsua_transport_create(type, config, &transport_id);
    
    if (status != PJ_SUCCESS)
        return status;
    
    if (transport_id == -1) {
        PJ_LOG(1,(THIS_FILE, "Error: no transport is configured"));
        status = -1;
    }
    
    return status;
}

static pj_status_t create_udp(pjsua_transport_config *config)
{
    return _create_network(config, PJSIP_TRANSPORT_UDP);
}

static pj_status_t create_tcp(pjsua_transport_config* config)
{
    return _create_network(config, PJSIP_TRANSPORT_TCP);


}


static void set_sip_agent(pj_str_t* agent)
{
    char tmp[80];
    int len;
    
    len = pj_ansi_sprintf(tmp, "GKsip v%s %s",
                          pj_get_version(),
                          pj_get_sys_info()->info.ptr);
    tmp[len] = '\0';
    
    pj_strdup2_with_null(gkSipConfig.pool, agent, tmp);
}