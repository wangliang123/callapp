//
//  GKSipClientState.h
//  GKSip
//
//  Created by Stupid on 12-9-17.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#ifndef __GKSIPCLIENTSTATE_H__
#define __GKSIPCLIENTSTATE_H__

typedef enum GKSipClientAccountState
{
    GKSipClientAccountStateOffline, // 离线
    GKSipClientAccountStateProcess, // 登录中
    GKSipClientAccountStateOnline // 在线
} GKSipClientAccountState;

typedef enum GKSipClientCallState
{
    GKSipClientCallStateCalling, // 拨号
    GKSipClientCallStateIncoming, // 来电
    GKSipClientCallStateConnecting, // 连接中
    GKSipClientCallStateConfirmed, // 建立通话
    GKSipClientCallStateDisconnected // 断开
} GKSipClientCallState;

#endif
