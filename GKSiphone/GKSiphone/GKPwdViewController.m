//
//  GKPwdViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-24.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKPwdViewController.h"

#import "AppDelegate.h"
#import "GKPwdCell.h"
#import "GKSipUser.h"

#define kUserNameTextFieldTag 1001
#define kPasswordTextFieldTag 1002
#define kHostUriTextFieldTag 1003

@interface GKPwdViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation GKPwdViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.tap = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    GK_SUPER_DEALLOC();
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    NSString *loginItemTitle = [GKSipUser shared].userHasLogin ? @"注销" : @"登录";
    
    UIBarButtonItem *loginBtnItem = [[UIBarButtonItem alloc] initWithTitle:loginItemTitle style:UIBarButtonItemStylePlain target:self action:@selector(handleLogin)];
    self.navigationItem.rightBarButtonItem = loginBtnItem;
    GK_RELEASE(loginBtnItem);
    
    self.title = [GKSipUser shared].userHasLogin ? @"账户已登录" : @"账户未登录";
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLoginStateChange)
                                                 name:kGKSipUserLoginStateChange
                                               object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLoginStateChange
{
    if ([GKSipUser shared].userHasLogin)
    {
        self.navigationItem.rightBarButtonItem.title = @"注销";
        self.title = @"账户已登录";
        [self.tableView reloadData];
        
        if (self.isModelViewController)
        {
            [self.navigationController dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"登录";
        self.title = @"账户未登录";
        [self.tableView reloadData];
    }
}

#pragma mark - Login
- (BOOL)check
{
    for (NSInteger index = 0; index < 3; ++index)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        GKPwdCell *pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
        if (pwdCell.textField.text == nil || [pwdCell.textField.text isEqualToString:@""] == YES)
            return NO;
    }
    
    return YES;
}

- (void)handleLogin
{
    if ([GKSipUser shared].userHasLogin)
    {
        [GKAppDelegate logout];
    }
    else
    {
        if ([self check])
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            GKPwdCell *pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
            [GKSipUser shared].userName = pwdCell.textField.text;
            [pwdCell.textField resignFirstResponder];
            path = [NSIndexPath indexPathForRow:1 inSection:0];
            pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
            [GKSipUser shared].password = pwdCell.textField.text;
            [pwdCell.textField resignFirstResponder];
            path = [NSIndexPath indexPathForRow:2 inSection:0];
            pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
            [GKSipUser shared].server = ServerCenter.infomation.domain;
            [GKSipUser shared].server = @"fengsheng.aoyi.power";
            [pwdCell.textField resignFirstResponder];
            [GKAppDelegate login];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入必填内容" message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alert show];
            GK_RELEASE(alert);
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GKPwdCell *cell = (GKPwdCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [(GKPwdCell *)[GKPwdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if ([GKSipUser shared].userHasLogin)
        {
            cell.textField.userInteractionEnabled = NO;
            cell.textField.textColor = [UIColor darkGrayColor];
        }
        else
        {
            cell.textField.userInteractionEnabled = YES;
            cell.textField.textColor = [UIColor blackColor];
        }
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.label.text = @"账户";
            [cell.textField setSecureTextEntry:NO];
            [cell.textField setReturnKeyType:UIReturnKeyNext];
            cell.textField.delegate = self;
            cell.textField.tag = kUserNameTextFieldTag;
            cell.textField.text = [GKSipUser shared].userName;            
        }
            break;
        case 1:
        {
            cell.label.text = @"密码";
            [cell.textField setSecureTextEntry:YES];
            [cell.textField setReturnKeyType:UIReturnKeyNext];
            cell.textField.delegate = self;
            cell.textField.tag = kPasswordTextFieldTag;
            cell.textField.text = [GKSipUser shared].password;
        }
            break;
        case 2:
        {
            cell.label.text = @"服务器";
            [cell.textField setSecureTextEntry:NO];
            [cell.textField setReturnKeyType:UIReturnKeyJoin];
            cell.textField.delegate = self;
            cell.textField.tag = kHostUriTextFieldTag;
            cell.textField.text = [GKSipUser shared].server;
           
            
        }
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark tap
- (void)handleTap
{ 
    for (NSInteger index = 0; index < 3; ++index)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        GKPwdCell *pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
        [pwdCell.textField resignFirstResponder];
    }
}


#pragma mark textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:HXQFTaskCreateCellTypeTitle];
//    [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    
    [self.view addGestureRecognizer:self.tap];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self.view removeGestureRecognizer:self.tap];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    switch (textField.tag)
    {
        case kUserNameTextFieldTag:
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
            GKPwdCell *pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
            [pwdCell.textField becomeFirstResponder];
        }
            break;
        case kPasswordTextFieldTag:
        {
            NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
            GKPwdCell *pwdCell = (GKPwdCell *) [self.tableView cellForRowAtIndexPath:path];
            [pwdCell.textField becomeFirstResponder];
        }
            break;
        case kHostUriTextFieldTag:
        {
            [textField resignFirstResponder];
            [self handleLogin];
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

@end
