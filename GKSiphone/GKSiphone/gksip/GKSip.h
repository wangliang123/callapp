//
//  GKSip.h
//  GKSip
//
//  Created by Stupid on 12-9-14.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIP_H__
#define __GKSIP_H__

#include <pjsua.h>

#include "GKSipClient.h"
#include "GKSipCall.h"
#include "GKSipAccount.h"

void pjstr_to_char(char* buf, const int buf_len, const pj_str_t* src);

#endif
