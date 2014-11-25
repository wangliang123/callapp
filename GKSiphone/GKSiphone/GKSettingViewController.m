//
//  GKSettingViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-24.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKSettingViewController.h"
#import "GKPwdViewController.h"
#import "ReferralViewController.h"
#import "AboutViewController.h"
#import "GKSipUser.h"


@interface GKSettingViewController ()

@end

@implementation GKSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"设置";
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16.];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.];
        GK_AUTORELEASE(cell);
    }
    
    switch (indexPath.section) {
        case 0:
        {
            if ([GKSipUser shared].userHasLogin)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"账户(%@)", [GKSipUser shared].userName];
                cell.detailTextLabel.text = @"已登录";
            }
            else
            {
                cell.textLabel.text = @"账户";
                cell.detailTextLabel.text = @"未登录";
            }
            
        }
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
//                    cell.textLabel.text = @"功能介绍";
                    cell.textLabel.text = @"关于软件";
                    cell.detailTextLabel.text = @"V1.0";
                    
                }
                    break;
//                case 1:
//                {
//                    
//                   
//                }
//                    break;
                
              
            }
        }
            break;
        default:
            break;
    }
    
    
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==0) {
        if (indexPath.row ==0) {
            GKPwdViewController *vc = [[GKPwdViewController alloc] initWithNibName:@"GKPwdViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            GK_RELEASE(vc);
        }
    }else if (indexPath.section ==1)
    {
        if (indexPath.row ==0) {
            
            AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:about animated:YES];
            GK_RELEASE(about);
        }
//        else if (indexPath.row==1)
//        {
//            ReferralViewController *Referral = [[ReferralViewController alloc] initWithNibName:@"ReferralViewController" bundle:nil];
//            [self.navigationController pushViewController:Referral animated:YES];
//            GK_RELEASE(Referral);
//        }
    }
    

}

@end
