//
//  GKSipCall.c
//  GKSip
//
//  Created by Stupid on 12-8-29.
//  Copyright (c) 2012年 Stupid. All rights reserved.
//

#include "GKSipCall.h"
#include "GKSipConfig.h"
#include "GKSipPool.h"


#define THIS_FILE	"GKSipCall.c"

/* Ringtones		        US	       UK  */
#define RINGBACK_FREQ1	    440	      /* 400 */
#define RINGBACK_FREQ2	    480	      /* 450 */
#define RINGBACK_ON	        2000      /* 400 */
#define RINGBACK_OFF	    4000      /* 200 */
#define RINGBACK_CNT	    1	      /* 2   */
#define RINGBACK_INTERVAL   4000      /* 2000 */

#define RING_FREQ1	        800
#define RING_FREQ2	        640
#define RING_ON		        200
#define RING_OFF	        100
#define RING_CNT	        3
#define RING_INTERVAL	    3000

/* Call specific data */
struct GKSipCallData
{
    pj_timer_entry	    timer;
    pj_bool_t		    ringback_on;
    pj_bool_t		    ring_on;
};

struct GKSipCall
{
    unsigned		           auto_answer;
    unsigned		           duration;
    
    pj_bool_t		           auto_play;
    pj_bool_t		           auto_play_hangup;
    pj_timer_entry	           auto_hangup_timer;
    
    struct GKSipCallData       call_data[PJSUA_MAX_CALLS];
    
    //pjsua_call_id              current_call_id;
    
    GKSipCallState             callState;
    GKSip_call_state_bc        bc;
    
    pjmedia_port	           *ringback_port;
    pjmedia_port	           *ring_port;
    int			               ringback_slot;
    int                        ring_slot;
};

typedef struct GKSipCall GKSipCall;

static GKSipCall *sipCall = NULL;

static pj_status_t create_ringback_tones(const pjsua_media_config *config)
{
    unsigned i, samples_per_frame;
    pj_status_t status;
    pjmedia_tone_desc tone[RING_CNT+RINGBACK_CNT];
    pj_str_t name;
    
    samples_per_frame = config->audio_frame_ptime * config->clock_rate * config->channel_count / 1000;
    
    /* Ringback tone (call is ringing) */
    name = pj_str("ringback");
    status = pjmedia_tonegen_create2(GKSip_default_pool(), &name,
                                     config->clock_rate,
                                     config->channel_count,
                                     samples_per_frame,
                                     16, PJMEDIA_TONEGEN_LOOP,
                                     &sipCall->ringback_port);
    if (status != PJ_SUCCESS)
        return status;
    
    pj_bzero(&tone, sizeof(tone));
    for (i=0; i<RINGBACK_CNT; ++i) {
        tone[i].freq1 = RINGBACK_FREQ1;
        tone[i].freq2 = RINGBACK_FREQ2;
        tone[i].on_msec = RINGBACK_ON;
        tone[i].off_msec = RINGBACK_OFF;
    }
    tone[RINGBACK_CNT-1].off_msec = RINGBACK_INTERVAL;
    
    pjmedia_tonegen_play(sipCall->ringback_port, RINGBACK_CNT, tone,
                         PJMEDIA_TONEGEN_LOOP);
    
    
    status = pjsua_conf_add_port(GKSip_default_pool(),
                                 sipCall->ringback_port,
                                 &sipCall->ringback_slot);
    if (status != PJ_SUCCESS)
        return status;
    
    /* Ring (to alert incoming call) */
    name = pj_str("ring");
    status = pjmedia_tonegen_create2(GKSip_default_pool(), &name,
                                     config->clock_rate,
                                     config->channel_count,
                                     samples_per_frame,
                                     16, PJMEDIA_TONEGEN_LOOP,
                                     &sipCall->ring_port);
    if (status != PJ_SUCCESS)
        return status;
    
    for (i=0; i<RING_CNT; ++i) {
        tone[i].freq1 = RING_FREQ1;
        tone[i].freq2 = RING_FREQ2;
        tone[i].on_msec = RING_ON;
        tone[i].off_msec = RING_OFF;
    }
    tone[RING_CNT-1].off_msec = RING_INTERVAL;
    
    pjmedia_tonegen_play(sipCall->ring_port, RING_CNT,
                         tone, PJMEDIA_TONEGEN_LOOP);
    
    status = pjsua_conf_add_port(GKSip_default_pool(),
                                 sipCall->ring_port,
                                 &sipCall->ring_slot);
    if (status != PJ_SUCCESS)
        return status;
    
    return PJ_SUCCESS;
}

static void notify(pjsua_call_id call_id,
                   GKSipCallState state,
                   pjsip_status_code status_code,
                   pj_str_t *remote_info)
{
    if (sipCall && sipCall->bc)
    {
        sipCall->bc(call_id, state, status_code, remote_info);
    }
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id,
                             pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pj_status_t status;
    
    status = pjsua_call_get_info(call_id, &ci);
    
    if (status == PJ_SUCCESS)
    {
        
        PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
                  (int)ci.remote_info.slen,
                  ci.remote_info.ptr));

        pjsua_call_setting call_opt;
        
        pjsua_call_setting_default(&call_opt);
        call_opt.aud_cnt = 1;
        call_opt.vid_cnt = 0;
        
        status = pjsua_call_answer2(call_id, &call_opt, PJSIP_SC_RINGING, NULL, NULL);
        
        if (status == PJ_SUCCESS)
        {
            notify(call_id, GKSipCallStateIncoming, ci.last_status, &ci.remote_info);
        }
    }
}


/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    
    
    PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id,
              (int)ci.state_text.slen,
              ci.state_text.ptr));
        
//    PJSIP_INV_STATE_NULL,	    /**< Before INVITE is sent or received  */
//    PJSIP_INV_STATE_CALLING,	    /**< After INVITE is sent		    */
//    PJSIP_INV_STATE_INCOMING,	    /**< After INVITE is received.	    */
//    PJSIP_INV_STATE_EARLY,	    /**< After response with To tag.	    */
//    PJSIP_INV_STATE_CONNECTING,	    /**< After 2xx is sent/received.	    */
//    PJSIP_INV_STATE_CONFIRMED,	    /**< After ACK is sent/received.	    */
//    PJSIP_INV_STATE_DISCONNECTED,   /**< Session is terminated.		    */
    
    switch (ci.state) {
        case PJSIP_INV_STATE_CALLING:
        {
            notify(call_id, GKSipCallStateCalling, ci.last_status, &ci.remote_info);
        }
            break;
        case PJSIP_INV_STATE_INCOMING:
        {
            notify(call_id, GKSipCallStateIncoming, ci.last_status, &ci.remote_info);
        }
            break;
        case PJSIP_INV_STATE_EARLY:
        {
        }
            break;
        case PJSIP_INV_STATE_CONNECTING:
        {
            notify(call_id, GKSipCallStateConnecting, ci.last_status, &ci.remote_info);
        }
            break;
        case PJSIP_INV_STATE_CONFIRMED:
        {
            notify(call_id, GKSipCallStateConfirmed, ci.last_status, &ci.remote_info);
        }
            break;
        case PJSIP_INV_STATE_DISCONNECTED:
        {
            notify(call_id, GKSipCallStateDisconnected, ci.last_status, &ci.remote_info);
        }
            break;
        default:
            break;
    }
    
}


/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

/* Callback from timer when the maximum call duration has been
 * exceeded.
 */
static void call_timeout_callback(pj_timer_heap_t *timer_heap,
                                  struct pj_timer_entry *entry)
{
    pjsua_call_id call_id = entry->id;
    pjsua_msg_data msg_data;
    pjsip_generic_string_hdr warn;
    pj_str_t hname = pj_str("Warning");
    pj_str_t hvalue = pj_str("399 pjsua \"Call duration exceeded\"");
    
    PJ_UNUSED_ARG(timer_heap);
    
    if (call_id == PJSUA_INVALID_ID) {
        //PJ_LOG(1,(THIS_FILE, "Invalid call ID in timer callback"));
        return;
    }
    
    /* Add warning header */
    pjsua_msg_data_init(&msg_data);
    pjsip_generic_string_hdr_init2(&warn, &hname, &hvalue);
    pj_list_push_back(&msg_data.hdr_list, &warn);
    
    //    /* Call duration has been exceeded; disconnect the call */
    //    PJ_LOG(3,(THIS_FILE, "Duration (%d seconds) has been exceeded "
    //              "for call %d, disconnecting the call",
    //              app_config.duration, call_id));
    entry->id = PJSUA_INVALID_ID;
    pjsua_call_hangup(call_id, PJSIP_SC_OK, NULL, &msg_data);
}


PJ_DEF(pj_status_t) GKSip_call_create(const pjsua_media_config *config)
{
    if (sipCall == NULL)
    {
        sipCall = (GKSipCall *)malloc(sizeof(GKSipCall));
        memset(sipCall, 0, sizeof(GKSipCall));
        
        sipCall->duration = (int)0x7FFFFFFF;
        
        /* Initialize calls data */
        for (int i=0; i<PJ_ARRAY_SIZE(sipCall->call_data); ++i) {
            sipCall->call_data[i].timer.id = PJSUA_INVALID_ID;
            sipCall->call_data[i].timer.cb = &call_timeout_callback;
        }
        
        sipCall->callState = GKSipCallStateDisconnected;
        
        sipCall->ringback_slot = PJSUA_INVALID_ID;
        sipCall->ring_slot = PJSUA_INVALID_ID;
        
        return create_ringback_tones(config);
    }
    
    return PJ_SUCCESS;
}

PJ_DEF(pj_status_t) GKSip_call_release(void)
{
    if (sipCall)
    {
        /* Close ringback port */
        if (sipCall->ringback_port &&
            sipCall->ringback_slot != PJSUA_INVALID_ID)
        {
            pjsua_conf_remove_port(sipCall->ringback_slot);
            sipCall->ringback_slot = PJSUA_INVALID_ID;
            pjmedia_port_destroy(sipCall->ringback_port);
            sipCall->ringback_port = NULL;
        }
        
        /* Close ring port */
        if (sipCall->ring_port && sipCall->ring_slot != PJSUA_INVALID_ID) {
            pjsua_conf_remove_port(sipCall->ring_slot);
            sipCall->ring_slot = PJSUA_INVALID_ID;
            pjmedia_port_destroy(sipCall->ring_port);
            sipCall->ring_port = NULL;
        }
        
        
        free(sipCall);
        sipCall = NULL;
    }
    
    return PJ_SUCCESS;
}

PJ_DEF(pj_status_t) GKSip_call_make_call(pj_str_t aUserId,
                                         pjsua_call_id *aCall_Id)
{
    pjsua_call_setting call_opt;
    pjsua_call_setting_default(&call_opt);
    call_opt.aud_cnt = 1;
    call_opt.vid_cnt = 0;
    
    pj_str_t tmp;
    pjsua_msg_data msg_data;
    pj_status_t status;
    
    tmp = aUserId;
    
    pjsua_msg_data_init(&msg_data);
    
    pjsua_call_id p_call_id;
    
    status = pjsua_call_make_call(pjsua_acc_get_default(),
                                  &tmp,
                                  &call_opt,
                                  NULL,
                                  &msg_data,
                                  &p_call_id);
    
    if (status == PJ_SUCCESS)
    {
        *aCall_Id = p_call_id;
    }
    else
    {
        *aCall_Id = PJSUA_INVALID_ID;
    }
    
    return status;
}

PJ_DEF(pj_status_t) GKSip_call_anwser(pjsua_call_id aCall_Id)
{
    return pjsua_call_answer(aCall_Id, PJSIP_SC_OK, NULL, NULL);
}

PJ_DEF(pj_status_t) GKSip_call_hangup(pjsua_call_id aCall_Id)
{
    return pjsua_call_hangup(aCall_Id, PJSIP_SC_DECLINE, NULL, NULL);
}

PJ_DECL(pj_status_t) GKSip_call_busy(pjsua_call_id aCall_Id)
{
    return pjsua_call_hangup(aCall_Id,
                             PJSIP_SC_BUSY_EVERYWHERE,
                             NULL, NULL);
}

PJ_DEF(void) GKSip_call_set_callback(GKSip_call_state_bc callback)
{
    sipCall->bc = callback;
}


/*
 * Handler when a transaction within a call has changed state.
 */
static void on_call_tsx_state(pjsua_call_id call_id,
                              pjsip_transaction *tsx,
                              pjsip_event *e)
{
    const pjsip_method info_method =
    {
        PJSIP_OTHER_METHOD,
        { "INFO", 4 }
    };
    
    if (pjsip_method_cmp(&tsx->method, &info_method)==0) {
        /*
         * Handle INFO method.
         */
        const pj_str_t STR_APPLICATION = { "application", 11};
        const pj_str_t STR_DTMF_RELAY  = { "dtmf-relay", 10 };
        pjsip_msg_body *body = NULL;
        pj_bool_t dtmf_info = PJ_FALSE;
        
        if (tsx->role == PJSIP_ROLE_UAC) {
            if (e->body.tsx_state.type == PJSIP_EVENT_TX_MSG)
                body = e->body.tsx_state.src.tdata->msg->body;
            else
                body = e->body.tsx_state.tsx->last_tx->msg->body;
        } else {
            if (e->body.tsx_state.type == PJSIP_EVENT_RX_MSG)
                body = e->body.tsx_state.src.rdata->msg_info.msg->body;
        }
        
        /* Check DTMF content in the INFO message */
        if (body && body->len &&
            pj_stricmp(&body->content_type.type, &STR_APPLICATION)==0 &&
            pj_stricmp(&body->content_type.subtype, &STR_DTMF_RELAY)==0)
        {
            dtmf_info = PJ_TRUE;
        }
        
        if (dtmf_info && tsx->role == PJSIP_ROLE_UAC &&
            (tsx->state == PJSIP_TSX_STATE_COMPLETED ||
             (tsx->state == PJSIP_TSX_STATE_TERMINATED &&
              e->body.tsx_state.prev_state != PJSIP_TSX_STATE_COMPLETED)))
        {
            /* Status of outgoing INFO request */
            if (tsx->status_code >= 200 && tsx->status_code < 300) {
                PJ_LOG(4,(THIS_FILE,
                          "Call %d: DTMF sent successfully with INFO",
                          call_id));
            } else if (tsx->status_code >= 300) {
                PJ_LOG(4,(THIS_FILE,
                          "Call %d: Failed to send DTMF with INFO: %d/%.*s",
                          call_id,
                          tsx->status_code,
                          (int)tsx->status_text.slen,
                          tsx->status_text.ptr));
            }
        } else if (dtmf_info && tsx->role == PJSIP_ROLE_UAS &&
                   tsx->state == PJSIP_TSX_STATE_TRYING)
        {
            /* Answer incoming INFO with 200/OK */
            pjsip_rx_data *rdata;
            pjsip_tx_data *tdata;
            pj_status_t status;
            
            rdata = e->body.tsx_state.src.rdata;
            
            if (rdata->msg_info.msg->body) {
                status = pjsip_endpt_create_response(tsx->endpt, rdata,
                                                     200, NULL, &tdata);
                if (status == PJ_SUCCESS)
                    status = pjsip_tsx_send_msg(tsx, tdata);
                
                PJ_LOG(3,(THIS_FILE, "Call %d: incoming INFO:\n%.*s",
                          call_id,
                          (int)rdata->msg_info.msg->body->len,
                          rdata->msg_info.msg->body->data));
                
            } else {
                status = pjsip_endpt_create_response(tsx->endpt, rdata,
                                                     400, NULL, &tdata);
                if (status == PJ_SUCCESS)
                    status = pjsip_tsx_send_msg(tsx, tdata);
            }
        }
    }
}


/*
 * 通话时的按键事件
 */
static void call_on_dtmf_callback(pjsua_call_id call_id, int dtmf)
{
    PJ_LOG(3,(THIS_FILE, "Incoming DTMF on call %d: %c", call_id, dtmf));
}


/*
 * 呼叫重定向事件
 */
static pjsip_redirect_op call_on_redirected(pjsua_call_id call_id,
                                            const pjsip_uri *target,
                                            const pjsip_event *e)
{
    PJ_UNUSED_ARG(e);
    
    if (gkSipConfig.redir_op == PJSIP_REDIRECT_PENDING) {
        char uristr[PJSIP_MAX_URL_SIZE];
        int len;
        
        len = pjsip_uri_print(PJSIP_URI_IN_FROMTO_HDR, target, uristr,
                              sizeof(uristr));
        if (len < 1) {
            pj_ansi_strcpy(uristr, "--URI too long--");
        }
        
        PJ_LOG(3,(THIS_FILE, "Call %d is being redirected to %.*s. "
                  "Press 'Ra' to accept, 'Rr' to reject, or 'Rd' to "
                  "disconnect.",
                  call_id, len, uristr));
    }
    
    return gkSipConfig.redir_op;
}

/*
 * sip账户状态改变事件
 */
static void on_reg_state(pjsua_acc_id acc_id)
{
    PJ_UNUSED_ARG(acc_id);
    
    // Log already written.
}

/**
 * 呼叫转移事件
 */
static void on_call_transfer_status(pjsua_call_id call_id,
                                    int status_code,
                                    const pj_str_t *status_text,
                                    pj_bool_t final,
                                    pj_bool_t *p_cont)
{
    PJ_LOG(3,(THIS_FILE, "Call %d: transfer status=%d (%.*s) %s",
              call_id, status_code,
              (int)status_text->slen, status_text->ptr,
              (final ? "[final]" : "")));
    
    if (status_code/100 == 2) {
        PJ_LOG(3,(THIS_FILE,
                  "Call %d: call transfered successfully, disconnecting call",
                  call_id));
        pjsua_call_hangup(call_id, PJSIP_SC_GONE, NULL, NULL);
        *p_cont = PJ_FALSE;
    }
}

/*
 * 呼叫替换事件
 */
static void on_call_replaced(pjsua_call_id old_call_id,
                             pjsua_call_id new_call_id)
{
    pjsua_call_info old_ci, new_ci;
    
    pjsua_call_get_info(old_call_id, &old_ci);
    pjsua_call_get_info(new_call_id, &new_ci);
    
    PJ_LOG(3,(THIS_FILE, "Call %d with %.*s is being replaced by "
              "call %d with %.*s",
              old_call_id,
              (int)old_ci.remote_info.slen, old_ci.remote_info.ptr,
              new_call_id,
              (int)new_ci.remote_info.slen, new_ci.remote_info.ptr));
}


/*
 * nat监测事件
 */
static void on_nat_detect(const pj_stun_nat_detect_result *res)
{
    if (res->status != PJ_SUCCESS) {
        pjsua_perror(THIS_FILE, "NAT detection failed", res->status);
    } else {
        PJ_LOG(3, (THIS_FILE, "NAT detected as %s", res->nat_type_name));
    }
}


/*
 * MWI事件
 */
static void on_mwi_info(pjsua_acc_id acc_id, pjsua_mwi_info *mwi_info)
{
    pj_str_t body;
    
    PJ_LOG(3,(THIS_FILE, "Received MWI for acc %d:", acc_id));
    
    if (mwi_info->rdata->msg_info.ctype) {
        const pjsip_ctype_hdr *ctype = mwi_info->rdata->msg_info.ctype;
        
        PJ_LOG(3,(THIS_FILE, " Content-Type: %.*s/%.*s",
                  (int)ctype->media.type.slen,
                  ctype->media.type.ptr,
                  (int)ctype->media.subtype.slen,
                  ctype->media.subtype.ptr));
    }
    
    if (!mwi_info->rdata->msg_info.msg->body) {
        PJ_LOG(3,(THIS_FILE, "  no message body"));
        return;
    }
    
    body.ptr = mwi_info->rdata->msg_info.msg->body->data;
    body.slen = mwi_info->rdata->msg_info.msg->body->len;
    
    PJ_LOG(3,(THIS_FILE, " Body:\n%.*s", (int)body.slen, body.ptr));
}


/*
 * 端口连接状态改变事件
 */
static void on_transport_state(pjsip_transport *tp,
                               pjsip_transport_state state,
                               const pjsip_transport_state_info *info)
{
    char host_port[128];
    
    pj_ansi_snprintf(host_port, sizeof(host_port), "[%.*s:%d]",
                     (int)tp->remote_name.host.slen,
                     tp->remote_name.host.ptr,
                     tp->remote_name.port);
    
    switch (state) {
        case PJSIP_TP_STATE_CONNECTED:
        {
            PJ_LOG(3,(THIS_FILE, "SIP %s transport is connected to %s",
                      tp->type_name, host_port));
        }
            break;
            
        case PJSIP_TP_STATE_DISCONNECTED:
        {
            char buf[100];
            
            snprintf(buf, sizeof(buf), "SIP %s transport is disconnected from %s",
                     tp->type_name, host_port);
            pjsua_perror(THIS_FILE, buf, info->status);
        }
            break;
            
        default:
            break;
    }
}

/*
 * 声音设备状态更改事件 
 */
static pj_status_t on_snd_dev_operation(int operation)
{
    PJ_LOG(3,(THIS_FILE, "Turning sound device %s", (operation? "ON":"OFF")));
    return PJ_SUCCESS;
}

PJ_DEF(void) GKSip_call_set_pj_callback(pjsua_callback *callback)
{
    callback->on_call_media_state = &on_call_media_state;
    callback->on_incoming_call = &on_incoming_call;
    callback->on_call_state = &on_call_state;
    
    // add by zhengjian
    
    callback->on_call_tsx_state = &on_call_tsx_state;
    callback->on_dtmf_digit = &call_on_dtmf_callback;
    callback->on_call_redirected = &call_on_redirected;
    callback->on_reg_state = &on_reg_state;
    //callback->on_incoming_subscribe = &on_incoming_subscribe;
    //callback->on_buddy_state = &on_buddy_state;
    //callback->on_buddy_evsub_state = &on_buddy_evsub_state;
    //callback->on_pager = &on_pager;
    //callback->on_typing = &on_typing;
    callback->on_call_transfer_status = &on_call_transfer_status;
    callback->on_call_replaced = &on_call_replaced;
    callback->on_nat_detect = &on_nat_detect;
    callback->on_mwi_info = &on_mwi_info;
    callback->on_transport_state = &on_transport_state;
    //callback->on_ice_transport_error = &on_ice_transport_error;
    callback->on_snd_dev_operation = &on_snd_dev_operation;
    //callback->on_call_media_event = &on_call_media_event;
}