//
//  GKSipConfig.c
//  PJSipDemo2
//
//  Created by Stupid on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include <stdio.h>
#include "GKSipConfig.h"

// sip和rtp监听的默认端口号
static unsigned rtp_port = 4000;
static unsigned udp_port = 6666;

// LOG日志的回调函数
pj_log_func *log_callback = NULL;

static pjsua_transport_config _get_network_config(const unsigned port)
{
    pjsua_transport_config cfg;
    pjsua_transport_config_default(&cfg);
    cfg.port = port;
    
    return cfg;
}

PJ_DEF(void) set_rtp_port(const unsigned port)
{
    rtp_port = port;
}

PJ_DEF(void) set_udp_port(const unsigned port)
{
    udp_port = port;
}

PJ_DEF(pjsua_config) get_pjsua_config(void)
{
    pjsua_config cfg;
    
    pjsua_config_default(&cfg);
    
    return cfg;
}

PJ_DEF(pjsua_logging_config) get_log_config(void)
{
    pjsua_logging_config cfg;
    pjsua_logging_config_default(&cfg);
    
    // 阻止显示PJSIP自身的消息
    cfg.level = 9;
    cfg.console_level = 3;
    
    cfg.cb = log_callback;
    
    return cfg;
}

PJ_DEF(pjsua_media_config) get_media_config(void)
{
    pjsua_media_config cfg;
    pjsua_media_config_default(&cfg);
    
    cfg.snd_rec_latency = PJMEDIA_SND_DEFAULT_REC_LATENCY;
    cfg.snd_play_latency = PJMEDIA_SND_DEFAULT_PLAY_LATENCY;
    cfg.clock_rate = 8000;
    
    return cfg;
}

PJ_DEF(pjsua_transport_config) get_udp_config(void)
{
    return _get_network_config(udp_port);
}

PJ_DEF(pjsua_transport_config) get_rtp_config(void)
{
    return _get_network_config(rtp_port);
}