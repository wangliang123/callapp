//
//  GKInfoViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKInfoViewController.h"
#import "AppDelegate.h"
#import "GKSipUser.h"

typedef enum _EGKTextFieldTag
{
    EGKTextFieldUserNameTag = 1001,
    EGKTextFieldPasswordTag = 1002,
    EGKTextFieldServerTag = 1003
} EGKTextFieldTag;

@interface GKInfoViewController ()

@end

@implementation GKInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"设置";
    }
    return self;
}

- (UITextField *)textFieldWithTag:(NSInteger)aTag
{
    return (UITextField *)[self.view viewWithTag:aTag];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UITextField *textField = [self textFieldWithTag:EGKTextFieldUserNameTag];

    textField.text = [GKSipUser shared].userName;
    
    textField = [self textFieldWithTag:EGKTextFieldPasswordTag];
    textField.text = [GKSipUser shared].password;

    textField = [self textFieldWithTag:EGKTextFieldServerTag];
    textField.text = [GKSipUser shared].server;
   

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

- (IBAction)handleBack:(UIButton *)aBtn
{
    if (isLogin ==YES) {
        return;
    }
    UITextField *userNameField = [self textFieldWithTag:EGKTextFieldUserNameTag];
    UITextField *passwordField = [self textFieldWithTag:EGKTextFieldPasswordTag];
    UITextField *serverField = [self textFieldWithTag:EGKTextFieldServerTag];
   
    if ([userNameField.text isEqualToString:[GKSipUser shared].userName] == NO || [passwordField.text isEqualToString:[GKSipUser shared].password] == NO ||
        [serverField.text isEqualToString:[GKSipUser shared].server] == NO)
    {
        [GKAppDelegate logout];
        
        [GKSipUser shared].userName = userNameField.text;
        [GKSipUser shared].password = passwordField.text;
        [GKSipUser shared].server = ServerCenter.infomation.domain;
        
        if ([GKSipUser shared].userName)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[GKSipUser shared].userName forKey:@"GKSipUserName"];
        }
        
        [GKAppDelegate login];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
