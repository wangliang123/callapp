//
//  GKSipPool.h
//  GKSip
//
//  Created by Stupid on 12-9-13.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPPOOL_H__
#define __GKSIPPOOL_H__

#include <pjsua-lib/pjsua.h>

PJ_BEGIN_DECL

PJ_DECL(void) GKSip_global_pool_init(void);
PJ_DECL(void) GKSip_global_pool_destroy(void);
PJ_DECL(pj_pool_t *) GKSip_default_pool(void);
PJ_DECL(pj_pool_t *) GKSip_create_pool(const char* name,
                                       pj_size_t size);

PJ_END_DECL

#endif
