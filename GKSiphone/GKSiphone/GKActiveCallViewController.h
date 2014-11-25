//
//  GKActiveCallViewController.h
//  GKSiphone
//
//  Created by Guogang on 13-1-28.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _EGKActiveCallUIState
{
    EGKActiveCallUIStateIncoming,
    EGKActiveCallUIStateMakeCall,
    EGKActiveCallUIStateEstablishing,
    EGKActiveCallUIStateCalling,
    EGKActiveCallUIStateDisconnect
} EGKActiveCallUIState;

@interface GKActiveCallViewController : UIViewController
{
    EGKActiveCallUIState _curState;
}

@property (nonatomic, strong) IBOutlet UIButton *rejectBtn;
@property (nonatomic, strong) IBOutlet UIButton *answerBtn;
@property (nonatomic, strong) IBOutlet UIButton *callRejectBtn;
@property (nonatomic, assign) NSInteger callId;
@property (nonatomic, assign) EGKActiveCallUIState UIState;
@property (nonatomic, strong) NSString *callName;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) IBOutlet UILabel *callNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *callTimer;
@property (nonatomic, assign) BOOL isIncomming;

- (IBAction)reject;
- (IBAction)answer;

// Starts call timer.
- (void)startCallTimer;

// Stops call timer.
- (void)stopCallTimer;

// Method to be called when call timer fires.
- (void)callTimerTick:(NSTimer *)theTimer;

@end
