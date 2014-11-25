//
//  GKSipSetting.h
//  GKSip
//
//  Created by Stupid on 12-9-18.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPSETTING_H__
#define __GKSIPSETTING_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

// 从XML加载数据
PJ_DECL(void) GKSip_setting_load(pj_pool_t *aPool,
                                 char *aData,
                                 pj_size_t aLen);

// 通过Key获取数据
PJ_DECL(const char *) GKSip_setting_value(const char *aKey);

// 释放内存
PJ_DECL(void) GKSip_setting_close(void);

PJ_END_DECL

#endif
