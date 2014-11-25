//
//  GKSipUa.h
//  PJSipDemo2
//
//  Created by Stupid on 12-8-20.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPUA_H__
#define __GKSIPUA_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

PJ_DECL(pj_status_t) GKSipUa_open(void);
PJ_DECL(pj_status_t) GKSipUa_close(void);

PJ_DECL(pjsua_transport_config *) GKSipUa_udp_cfg(void);
PJ_DECL(pjsua_transport_config *) GKSipUa_rtp_cfg(void);



PJ_END_DECL

#endif
