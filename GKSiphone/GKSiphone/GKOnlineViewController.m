//
//  GKOnlineViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-29.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKOnlineViewController.h"

@interface GKOnlineViewController ()

@end

@implementation GKOnlineViewController

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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"在线";
    
    UIBarButtonItem *reloadBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleReload)];
    self.navigationItem.rightBarButtonItem = reloadBtnItem;
    GK_RELEASE(loginBtnItem);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleReload
{}

@end
