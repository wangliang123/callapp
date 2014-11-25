//
//  GKCallViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKCallViewController.h"
#import "GKContactViewController.h"
#import "GKSip.h"
#import "UIGlossyButton.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"


static SystemSoundID sounds[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

@interface GKCallViewController ()

@property (nonatomic, strong) NSMutableString *dialText;

@end

#define kZeroButtonTag 1000

@implementation GKCallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.callBtn.titleLabel.shadowOffset = CGSizeMake(0,-1);
    self.callBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.callBtn setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.callBtn setTitleShadowColor:[UIColor colorWithWhite:0. alpha:0.2]  forState:UIControlStateDisabled];
    [self.callBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.callBtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0]  forState:UIControlStateDisabled];
    [self.view addSubview:self.callBtn];
    
    [self.dialLabel.layer setCornerRadius:2.0];
    [self.dialLabel.layer setBorderWidth:1.0];
    [self.dialLabel setBackgroundColor:[UIColor colorWithRed:70.0f/255.0f green:105.0f/255.0f blue:192.0f/255.0f alpha:1.0f]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youObserv:) name:@"eit" object:nil];
    
}
-(void)youObserv:(NSNotification*)noti
{

    NSDictionary *dict = [noti userInfo];
    NSString *str = [dict objectForKey:@"userID"];
    _dialLabel.text = str;
    _dialText = [NSMutableString stringWithString:str];
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{

    self.dialText = nil;
    self.dialLabel = nil;
    self.statusLabel = nil;
    self.callBtn = nil;
    
    for (int index = 0; index < 13; ++index)
    {
        if (sounds[index])
        {
            AudioServicesDisposeSystemSoundID(sounds[index]);
            sounds[index] = 0;
        }
    }
    
    GK_SUPER_DEALLOC();
}

- (IBAction)handleDialBtn:(UIButton *)aBtn
{

    NSInteger btnKey = aBtn.tag - kZeroButtonTag;
    char key;
    if (btnKey == 10)
    {
        key = '*';
    }
    else if (btnKey == 11)
    {
        key = '#';
    }
    else
    {
        key = '0' + btnKey;
    }
    
    if (self.dialText)
    {
        [self.dialText appendFormat:@"%c", key];
    }
    else
    {
        self.dialText = [NSMutableString stringWithFormat:@"%c", key];
    }
    
    self.dialLabel.text = self.dialText;
    
}

- (IBAction)handleDialAudio:(UIButton *)aBtn
{

     NSInteger btnKey = aBtn.tag - kZeroButtonTag;
    
    if (!sounds[btnKey])
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filename = [NSString stringWithFormat:@"dtmf-%d", btnKey];
        NSString *path = [mainBundle pathForResource:filename ofType:@"aif"];
        if (!path)
            return;
        
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        if (aFileURL != nil)
        {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL,
                                                              &aSoundID);
            if (error != kAudioServicesNoError)
                return;
            
            sounds[btnKey] = aSoundID;
        }
    }
    
    AudioServicesPlaySystemSound(sounds[btnKey]);
}

- (IBAction)handleClearBtn:(UIButton *)aBtn
{

    if ([self.dialText length])
    {
        NSRange range;
        range.length = 1;
        range.location = [self.dialText length] - 1;
        [self.dialText deleteCharactersInRange:range];
    }
    
    self.dialLabel.text = self.dialText;
}

- (IBAction)handleCallBtn:(UIButton *)aBtn
{

    
    if ([self.dialLabel.text isEqualToString:@""] == NO)
    {   
        NSString *userId = [NSString stringWithFormat:@"%@", self.dialLabel.text];
//        NSString *NewId = [userId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [userId stringByReplacingOccurrencesOfString:@" " withString:@""];
        [userId stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [GKAppDelegate makeCall:userId];

    }
}

- (IBAction)handleContactBtn:(UIButton *)aBtn
{

    GKAppDelegate.tabViewController.selectedIndex = 1;
  
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    NSString *string = self.dialLabel.text;
    ABRecordRef newPerson = ABPersonCreate();
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValue, (__bridge CFTypeRef)(string), kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiValue , &error);
    NSAssert(!error, @"Something bad happened here.");
    picker.displayedPerson = newPerson;
	picker.newPersonViewDelegate = self;
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    navigation.navigationBar.barStyle = UIBarStyleBlack;
	[self presentModalViewController:navigation animated:YES];
    GK_RELEASE(picker);
    GK_RELEASE(navigation);
   
    
    
}

#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{

	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{

	return NO;
}


@end
