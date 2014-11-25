//
//  GKSipSetting.c
//  GKSip
//
//  Created by Stupid on 12-9-18.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipSetting.h"

struct GKSipSetting
{
    pj_rbtree *settingTree;
};

char *kSettingKey[] = {
    "server",
    "clientname"
};

typedef struct GKSipSetting GKSipSetting;

static GKSipSetting* defaultSetting = NULL;

static int setting_rbtree_comp(const void *key1, const void *key2)
{
    return strcmp((const char *)key1, (const char *)key2);
}

static GKSipSetting* defaultSipSetting(void)
{
    if (defaultSetting == NULL)
    {
        defaultSetting = (GKSipSetting *)malloc(sizeof(GKSipSetting));
        defaultSetting->settingTree = (pj_rbtree *)malloc(PJ_RBTREE_SIZE);
        pj_rbtree_init(defaultSetting->settingTree, setting_rbtree_comp);
    }
    return defaultSetting;
}

#define CurSipSetting defaultSipSetting()

static void freeTree(pj_rbtree *aTree)
{
    pj_rbtree_node *node = pj_rbtree_first(aTree);
    
    while (node) {
        node = pj_rbtree_erase(aTree, node);
        if (node->key)
        {
            free((void *)node->key);
            node->key = NULL;
        }
        if (node->user_data)
        {
            free((void *)node->user_data);
            node->user_data = NULL;
        }
        free(node);
        node = NULL;
        
        node = pj_rbtree_first(aTree);
    }
}

static void releaseSipSetting(void)
{
    if (defaultSetting)
    {
        if (defaultSetting->settingTree)
        {
            freeTree(defaultSetting->settingTree);
            free(defaultSetting->settingTree);
            defaultSetting->settingTree = NULL;
        }
        
        free(defaultSetting);
        defaultSetting = NULL;
    }
}

static void setSettingNode(pj_xml_node *aXmlNode, const char *aKey)
{
    if (aXmlNode)
    {
        pj_rbtree_node *treeNode = (pj_rbtree_node *)malloc(PJ_RBTREE_NODE_SIZE);
        
        if (aXmlNode->content.ptr)
        {
            char *buffer = (char *)malloc(aXmlNode->content.slen+1);
            memset(buffer, 0, aXmlNode->content.slen+1);
            memcpy(buffer, aXmlNode->content.ptr, aXmlNode->content.slen);
            treeNode->user_data = buffer;
        }
        
        if (aXmlNode->name.ptr)
        {
            char *buffer = (char *)malloc(aXmlNode->name.slen+1);
            memset(buffer, 0, aXmlNode->name.slen+1);
            memcpy(buffer, aXmlNode->name.ptr, aXmlNode->name.slen);
            treeNode->key = buffer;
        }
        
        if (pj_rbtree_insert(CurSipSetting->settingTree, treeNode) != PJ_SUCCESS)
        {
            //  如果返回值不为0,说明插入失败,此时需要释放掉treeNode的内存
            if (treeNode->key)
            {
                free((void *)treeNode->key);
                treeNode->key = NULL;
            }
            if (treeNode->user_data)
            {
                free((void *)treeNode->user_data);
                treeNode->user_data = NULL;
            }
            
            free(treeNode);
            treeNode = NULL;
        }
    }
}

PJ_DEF(void) GKSip_setting_close(void)
{
    releaseSipSetting();
}

PJ_DEF(void) GKSip_setting_load(pj_pool_t *aPool,
                                char *aData,
                                pj_size_t aLen)
{
    pj_xml_node *rootNode = pj_xml_parse(aPool, aData, aLen);
    
    unsigned int settingKeyCount = sizeof(kSettingKey)/sizeof(kSettingKey[0]);
    
    for (int index = 0; index < settingKeyCount; ++index)
    {
        pj_str_t ipStr = pj_str(kSettingKey[index]);
        pj_xml_node *node = pj_xml_find_node(rootNode, &ipStr);
        setSettingNode(node, kSettingKey[index]);
    }
}

PJ_DEF(const char *) GKSip_setting_value(const char *aKey)
{
    if (aKey)
    {
        pj_rbtree_node * node = pj_rbtree_find(CurSipSetting->settingTree, aKey);
        if (node)
        {
            return (const char *)node->user_data;
        }
    }
    
    return NULL;
}