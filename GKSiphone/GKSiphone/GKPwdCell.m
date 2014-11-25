//
//  GKPwdCell.m
//  GKSiphone
//
//  Created by Guogang on 13-1-24.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKPwdCell.h"

@implementation GKPwdCell

- (void)config
{
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self config];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10,0,60,44)];
        self.label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.label];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(70,2,250,40)];
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.placeholder = @"必填项";
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.font = [UIFont systemFontOfSize:14.0f];
        //self.account.delegate = self;
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
        //self.account.textColor = [UIColor colorWithHex:0xFF404040];
        self.textField.clearButtonMode = UITextFieldViewModeAlways;
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)dealloc
{
    self.textField = nil;
    self.label = nil;
    
    GK_SUPER_DEALLOC();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [self config];
}

@end
