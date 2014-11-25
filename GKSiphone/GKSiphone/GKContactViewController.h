//
//  GKContactViewController.h
//  GKSiphone
//
//  Created by Guogang on 13-1-19.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GKCallViewController.h"
#import "GKActiveCallViewController.h"
@interface GKContactViewController : UITableViewController <UISearchDisplayDelegate, ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    GKContactViewController *controller;
    GKCallViewController *CallController;

    NSString *UserID;
}
@property (nonatomic,copy) NSString *UserID;
-(void)loadContacts;

@end
