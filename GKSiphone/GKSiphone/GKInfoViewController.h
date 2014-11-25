//
//  GKInfoViewController.h
//  GKSiphone
//
//  Created by Guogang on 13-1-10.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKInfoViewController : UIViewController <UITextFieldDelegate>
{
    BOOL isLogin;
}

- (IBAction)handleBack:(UIButton *)aBtn;

@end
