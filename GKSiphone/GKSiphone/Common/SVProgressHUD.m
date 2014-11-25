//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

#define SVStance   [SVProgressHUD instance]

static SVProgressHUD *SVHUD = nil;

@interface SVProgressHUD ()

@property (nonatomic,strong) NSMutableArray *listMessage;
@property (nonatomic,strong) UIImageView *backView;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

+ (SVProgressHUD *)instance;

- (void)dismissMessage;

@end

@implementation SVProgressHUD

@synthesize listMessage;
@synthesize backView;
@synthesize activityView;

+ (SVProgressHUD *)instance {
    
    @synchronized(self)
    {
        if (SVHUD == nil)
        {
            SVHUD = [[SVProgressHUD alloc] init];
        }
    }
    
    return SVHUD;
}

+ (void)dismiss {
    
    [SVProgressHUD cancelPreviousPerformRequestsWithTarget:SVStance];
    
    if (SVStance.listMessage && 0 < SVStance.listMessage.count)
    {
        [SVStance dismissMessage];
    }
    else
    {
        SVStance.listMessage = [NSMutableArray array];
    }
}

+ (void)showMessage:(NSString *)title duration:(NSTimeInterval)duration {
    
    if (duration <= 0.0f || 2.0f <= duration)
    {
        duration = 2.0f;
    }
    
    [self dismiss];
    
    int width = 300;
    int height = 32;
    UIFont *messageFont = [UIFont systemFontOfSize:13.0f];
    CGSize size = [title sizeWithFont:messageFont constrainedToSize:CGSizeMake(150.0f,1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    if (size.width < 100)
    {
        width = 100;
    }
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    SVStance.backView = [[UIImageView alloc] initWithFrame:CGRectMake((bounds.size.width-width)/2,bounds.size.height-70-height-3,width,height)];
    SVStance.backView.userInteractionEnabled = YES;
    SVStance.backView.backgroundColor = [UIColor clearColor];
    SVStance.backView.image = [[UIImage imageNamed:@"tipdisbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10,6,10,6)];
    [APPDelegate.window addSubview:SVStance.backView];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width-width)/2,bounds.size.height-70-height-3,width,height)];
    message.backgroundColor = [UIColor clearColor];
    message.font = messageFont;
    message.text = title;
    message.textColor = [UIColor whiteColor];
    message.highlightedTextColor = [UIColor whiteColor];
    message.textAlignment = NSTextAlignmentCenter;
    [SVStance.listMessage addObject:message];
    [APPDelegate.window addSubview:message];
    
    [SVStance performSelector:@selector(dismissMessage) withObject:nil afterDelay:duration];
}

- (void)dismissMessage {

    [SVStance.listMessage makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [SVStance.backView removeFromSuperview];
    SVStance.backView = nil;
    [SVStance.activityView stopAnimating];
    SVStance.activityView = nil;
    SVStance.listMessage = [NSMutableArray array];
}

+ (void)showLoading {

    [self dismiss];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    UIView *bgView = [[UIView alloc] initWithFrame:bounds];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.3f;
    [SVStance.listMessage addObject:bgView];
    [APPDelegate.window addSubview:bgView];
    
    SVStance.backView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,80,80)];
    SVStance.backView.userInteractionEnabled = YES;
    SVStance.backView.backgroundColor = [UIColor blackColor];
    SVStance.backView.center = APPDelegate.window.center;
    SVStance.backView.alpha = 0.8f;
    SVStance.backView.layer.cornerRadius = 5;
    SVStance.backView.layer.masksToBounds = YES;
    [APPDelegate.window addSubview:SVStance.backView];
    
    SVStance.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    SVStance.activityView.center = APPDelegate.window.center;
    [SVStance.activityView startAnimating];
    [APPDelegate.window addSubview:SVStance.activityView];
}



@end
