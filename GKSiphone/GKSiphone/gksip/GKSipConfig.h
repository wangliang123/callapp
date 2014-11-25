//
//  GKSipConfig.h
//  PJSipDemo2
//
//  Created by Stupid on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPCONFIG_H__
#define __GKSIPCONFIG_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL
    
PJ_DECL(pjsua_config)  get_pjsua_config(void);
PJ_DECL(pjsua_logging_config) get_log_config(void);
PJ_DECL(pjsua_media_config) get_media_config(void);
PJ_DECL(pjsua_transport_config) get_udp_config(void);
PJ_DECL(pjsua_transport_config) get_rtp_config(void);

// 更改sip和udp的默认监听端口号，必须在create_network()调用才有效。
PJ_DECL(void) set_udp_port(const unsigned port);
PJ_DECL(void) set_rtp_port(const unsigned port);

typedef struct GKSipConfig
{
    pj_pool_t              *pool;
    pjsua_config           cfg;
    pjsua_logging_config   log_cfg;
    pjsua_media_config     media_cfg;
    pjsua_transport_config udp_cfg;
    pjsua_transport_config rtp_cfg;
    pjsip_redirect_op	    redir_op;

} GKSipConfig;

GKSipConfig gkSipConfig;

PJ_END_DECL
    
#endif
