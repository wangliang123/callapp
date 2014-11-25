//
//  GKLogViewController.h
//  GKSiphone
//
//  Created by Guogang on 13-1-24.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKLogViewController : UITableViewController
{
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_weekdayFormatter;
    NSDateFormatter *_hourFormatter;
}
@end
