
//
//  GKActiveCallViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-28.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKActiveCallViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GKSipLog.h"
#import "GKSipLogDB.h"
#import "GKCallViewController.h"

@interface GKActiveCallViewController ()

@property (nonatomic, assign) SystemSoundID soundID;

@end


@implementation GKActiveCallViewController


- (void)configButton:(UIButton *)button
               title:(NSString *)title
               image:(UIImage *)image
          background:(UIImage *)backgroundImage
   backgroundPressed:(UIImage *)backgroundImagePressed
{
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    
    if (image)
    {
        [button setImage:image forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake (0., 0., 0., 5.);
    }
	
	UIImage *newImage = [backgroundImage stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [backgroundImagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configRejectBtn
{
    UIImage *buttonBackground = [UIImage imageNamed:@"bottombarred.png"];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"bottombarred_pressed.png"];
    UIImage *image = [UIImage imageNamed:@"decline.png"];
    
    [self configButton:self.rejectBtn
                 title:@"拒绝"
                 image: image
            background: buttonBackground
     backgroundPressed: buttonBackgroundPressed];
    
    [self configButton:self.callRejectBtn
                 title:@"挂断"
                 image: image
            background: buttonBackground
     backgroundPressed: buttonBackgroundPressed];
}

- (void)configAnswerBtn
{
    UIImage *buttonBackground = [UIImage imageNamed:@"bottombargreen.png"];
    UIImage *buttonBackgroundPressed = [UIImage imageNamed:@"bottombargreen_pressed.png"];
    UIImage *image = [UIImage imageNamed:@"answer.png"];
    
    [self configButton:self.answerBtn
                 title:@"接听"
                 image: image
            background: buttonBackground
     backgroundPressed: buttonBackgroundPressed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.


    [self configRejectBtn];
    [self configAnswerBtn];
    
    self.callNameLabel.text = self.callName;
    [self setUIState:_curState];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static void completionCallback(SystemSoundID  mySSID, void* clientData)
{
    // Play again after sound play completion


   GKActiveCallViewController *vc = (__bridge_transfer  GKActiveCallViewController *)clientData;

    if (vc.UIState == EGKActiveCallUIStateIncoming)
    {
        
        AudioServicesPlaySystemSound(mySSID);
    }
//    CFRelease(clientData);
//    CFRunLoopStop(CFRunLoopGetCurrent());

}

- (void)playIncomingSound
{
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    NSString *path = [mainBundle pathForResource:@"ring" ofType:@"wav"];
//    
//    NSURL *aFileURL = [NSURL fileURLWithPath:path
//                                 isDirectory:NO];
//    
//    SystemSoundID aSoundID;
//    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL,
//                                                      &aSoundID);
//    if (error != kAudioServicesNoError)
//        return;
//    
//    self.soundID = aSoundID;
//    
//    AudioServicesAddSystemSoundCompletion (self.soundID,
//                                           NULL ,
//                                           NULL ,
//                                           completionCallback,
//                                           (__bridge void *) self );
//    
//    AudioServicesPlaySystemSound(self.soundID);
    
   
    
    CFBundleRef mainBundle;
    SystemSoundID soundFileObject;
    mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("ring"), CFSTR("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    AudioServicesAddSystemSoundCompletion (self.soundID,  NULL , NULL ,  completionCallback,(__bridge void *) self );
    
    AudioServicesPlayAlertSound(soundFileObject);
}

- (void)stopIncomingSound
{


    if (self.soundID)
    {
        AudioServicesDisposeSystemSoundID(self.soundID);
        self.soundID = 0;
    }
}

- (void)setUIState:(EGKActiveCallUIState)aUIState
{


    _curState = aUIState;
    
    switch (_curState) {
        case EGKActiveCallUIStateIncoming:
        {
            self.callRejectBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.answerBtn.hidden = NO;
            
            [self playIncomingSound];
            self.timeLabel.text = @"来电";
        }
            break;
        case EGKActiveCallUIStateMakeCall:
        {
            self.callRejectBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.answerBtn.hidden = YES;
            self.timeLabel.text = @"正在呼叫";
        }
            break;
        case EGKActiveCallUIStateCalling:
        {
            self.callRejectBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.answerBtn.hidden = YES;
            
            [self stopIncomingSound];
            [self startCallTimer];
        }
            break;
        case EGKActiveCallUIStateDisconnect:
        {
            GKSipLog *log = [[GKSipLog alloc] init];
            
            log.callName = self.callName;
            log.logId = self.callId;
            NSString *string =[NSString stringWithFormat:@"%d",self.callId];
            NSLog(@"%@",string);
//            log.callID = string;

            if (self.startTime) // 接通后挂断
            {
                log.startTime = self.startTime;
                log.finishedTime = [NSDate timeIntervalSinceReferenceDate];
            }
            else // 未接通直接挂断
            {
                log.startTime = [NSDate timeIntervalSinceReferenceDate];
                log.finishedTime = log.startTime;
                [self stopIncomingSound];
                
            }
            
            if (self.isIncomming)
            {
                log.callType = 1;
            }
            else
            {
                log.callType = 0;
            }
            
            [[GKSipLogDB shared] insertLog:log];
            GK_RELEASE(log);
            log = nil;
            
            [self stopIncomingSound];
            [self stopCallTimer];
            
            [self dismissModalViewControllerAnimated:YES];

            GKAppDelegate.activeCallVC = nil;
        }
            break;
            
            
        default:
            break;
    }
}

- (EGKActiveCallUIState)UIState
{

    return _curState;
}

- (IBAction)reject
{


    [GKAppDelegate endCall:self.callId];
}

- (IBAction)answer
{


    if (_curState == EGKActiveCallUIStateIncoming)
    {
        _curState = EGKActiveCallUIStateEstablishing;
        [GKAppDelegate answerCall:self.callId];
    }
}

// Starts call timer.
- (void)startCallTimer
{
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.callTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                      target:self
                                                    selector:@selector(callTimerTick:)
                                                    userInfo:nil
                                                     repeats:YES];
}

// Stops call timer.
- (void)stopCallTimer
{
    [self.callTimer invalidate];
    self.callTimer = nil;
}

// Method to be called when call timer fires.
- (void)callTimerTick:(NSTimer *)theTimer
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSInteger seconds = (NSInteger)(now - self.startTime);
    
    if (seconds < 3600)
    {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                               (seconds / 60) % 60,
                               seconds % 60];
    }
    else
    {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                               (seconds / 3600) % 24,
                               (seconds / 60) % 60,
                               seconds % 60];
    }
}


@end
