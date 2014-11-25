//
//  GKCallViewController.h
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
@interface GKCallViewController : UIViewController<ABNewPersonViewControllerDelegate>

- (IBAction)handleDialBtn:(UIButton *)aBtn;
- (IBAction)handleDialAudio:(UIButton *)aBtn;
- (IBAction)handleClearBtn:(UIButton *)aBtn;
- (IBAction)handleCallBtn:(UIButton *)aBtn;
- (IBAction)handleContactBtn:(UIButton *)aBtn;

@property (nonatomic, strong) IBOutlet UILabel *dialLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIButton *callBtn;

@end
