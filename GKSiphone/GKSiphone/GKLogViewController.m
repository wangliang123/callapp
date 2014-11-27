//
//  GKLogViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-24.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKLogViewController.h"
#import "GKSipLogDB.h"
#import "GKSipLog.h"
#import "AppDelegate.h"

@interface GKLogViewController ()

@property (nonatomic, strong) NSMutableArray *logs;

@end

@implementation GKLogViewController

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
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *editBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(handleEdit:)];
    
    self.navigationItem.rightBarButtonItem = editBtnItem;
    self.title = @"最近通话";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.contentTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景.png"]];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    
    NSArray *logs = [[GKSipLogDB shared] allLogs];
    self.logs = [NSMutableArray arrayWithArray:logs];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{

    GK_RELEASE(_dateFormatter);
    GK_RELEASE(_weekdayFormatter);
    GK_RELEASE(_hourFormatter);
    GK_SUPER_DEALLOC();
}

- (void)handleEdit:(UIBarButtonItem *)aItem
{

    if (self.tableView.isEditing)
    {
        [aItem setStyle:UIBarButtonItemStylePlain];
        [aItem setTitle:@"编辑"];
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        [aItem setStyle:UIBarButtonItemStyleDone];
        [aItem setTitle:@"完成"];
        [self.tableView setEditing:YES animated:YES];
    }
}

- (NSDateFormatter *)dateFormatter
{

	if (_dateFormatter == nil)
	{
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[_dateFormatter setDoesRelativeDateFormatting:YES];
	}
	return _dateFormatter;
}

- (NSDateFormatter *)weekdayFormatter
{

    if (_weekdayFormatter == nil)
    {
        _weekdayFormatter = [[NSDateFormatter alloc] init];
        [_weekdayFormatter setDateFormat:@"EEEE"];
        // Maybe we should call setDefaultDate too
    }
    return _weekdayFormatter;
}

- (NSDateFormatter *)hourFormatter
{

	if (_hourFormatter == nil)
	{
		_hourFormatter = [[NSDateFormatter alloc] init];
		[_hourFormatter setDateStyle:NSDateFormatterNoStyle];
		[_hourFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	return _hourFormatter;
}

- (NSString *)stringFromDate:(NSDate *)aDate
{

	// TODO manage the future
	NSDate *today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                     fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	if ([aDate compare:midnight] == NSOrderedDescending)
		return [[self hourFormatter] stringFromDate:aDate];
	else
	{
		// check if date is between yesterday and 7 last days.
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-1];
		NSDate *yesterday = [calendar dateByAddingComponents:componentsToSubtract
                                                      toDate:midnight options:0];
		[componentsToSubtract setDay:-6];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract
                                                     toDate:midnight options:0];
        GK_RELEASE(componentsToSubtract);
        
		if ([aDate compare:lastweek] == NSOrderedDescending &&
            [aDate compare:yesterday] == NSOrderedAscending)
			return [[self weekdayFormatter] stringFromDate:aDate];
	}
	return [[self dateFormatter] stringFromDate:aDate];
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
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        GK_AUTORELEASE(cell);
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16.];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.];
        UIImageView *callImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"answer.png"]];
        callImgView.frame = CGRectMake(0., 0., 22., 22.);
        callImgView.center = CGPointMake(0., 22.);
        callImgView.hidden = YES;
        callImgView.tag = 1001;
        [cell.contentView addSubview:callImgView];
        GK_RELEASE(callImgView);
    }
    
    GKSipLog *log = [self.logs objectAtIndex:indexPath.row];
    cell.textLabel.text = log.callName;
    
    NSDate *callDate = [NSDate dateWithTimeIntervalSinceReferenceDate:log.startTime];
    cell.detailTextLabel.text = [self stringFromDate:callDate];
    
    UIImageView *callImgView = (UIImageView *)[cell viewWithTag:1001];
    
    switch (log.callType) {
        case 0: // 呼叫
        {
            CGSize textSize = [log.callName sizeWithFont:cell.textLabel.font];
            callImgView.hidden = NO;
            callImgView.center = CGPointMake(textSize.width + 25., 22.);            
            cell.textLabel.textColor = [UIColor darkTextColor];
        }
            break;
        case 1: // 被叫
        {
            callImgView.hidden = YES;
            cell.textLabel.textColor = [UIColor darkTextColor];
        }
            break;
        case 2: // 未接
        {
            callImgView.hidden = YES;
            cell.textLabel.textColor = [UIColor redColor];
        }
            break;
        default:
            break;
    }
    
    
    // Configure the cell...
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    GKSipLog *log = [self.logs objectAtIndex:indexPath.row];
    [[GKSipLogDB shared] removeLogWithStartTime:log.startTime];
    [self.logs removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

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
    
    GKSipLog *log = [self.logs objectAtIndex:indexPath.row];
    [GKAppDelegate makeCall:log.callName];
    
}

@end
