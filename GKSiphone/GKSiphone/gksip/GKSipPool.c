//
//  GKSipPool.c
//  GKSip
//
//  Created by Stupid on 12-9-13.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipPool.h"

#define THIS_FILE "GKSipPool.c"

// 整个缓冲区最大可以配置4M内存
#define KB 1024
#define MAX_POOL_SIZE 1024 * 1024 * 4

static pj_caching_pool caching_pool;
static pj_pool_t *defaultPool = NULL;

PJ_DEF(void) GKSip_global_pool_init(void)
{
    // pj_init()里面有引用计数, 不需要担心重复初始化,
    // 不过需要在析构的时候调用 pj_shutdown(),
    // 使其引用计数减1
    pj_init();
    
    pj_caching_pool_init( &caching_pool, NULL, MAX_POOL_SIZE );
}

PJ_DEF(void) GKSip_global_pool_destroy(void)
{
    if (defaultPool)
    {
        pj_pool_release(defaultPool);
        defaultPool = NULL;
    }
    pj_caching_pool_destroy( &caching_pool );
    pj_shutdown();
}

PJ_DECL(pj_pool_t *) GKSip_default_pool(void)
{
    if (defaultPool == NULL)
    {
        GKSip_global_pool_init();
        
        defaultPool = GKSip_create_pool("GKSip_Default_Pool", 4096);
    }
    
    return defaultPool;
}

static void pool_error(const char *title, pj_status_t status)
{
    char error_msg[PJ_ERR_MSG_SIZE];
    
    pj_strerror(status, error_msg, sizeof(error_msg));
    
    PJ_LOG(1, (THIS_FILE, "%s: %s [status=%d]", title, error_msg, status));
}


PJ_DECL(pj_pool_t *) GKSip_create_pool(const char* name,
                                       pj_size_t size)
{
    pj_pool_t* pool;
    
    pool = pj_pool_create(&caching_pool.factory, name, size, size, NULL);
    
    if (pool == NULL) {
        pool_error("Error creating pool", PJ_ENOMEM);
    }
    
    return pool;
}