//
//  GKContactViewController.m
//  GKSiphone
//
//  Created by Guogang on 13-1-19.
//  Copyright (c) 2013年 GK. All rights reserved.
//

#import "GKContactViewController.h"
#import "pinyin.h"
#import "POAPinyin.h"
#import "GKConfig.h"
#import "AppDelegate.h"
@interface GKContactViewController ()

@property (nonatomic, strong) NSMutableDictionary *sectionDic;
@property (nonatomic, strong) NSMutableDictionary *phoneDic;
@property (nonatomic, strong) NSMutableDictionary *contactDic;
@property (nonatomic, strong) NSMutableArray *filteredArray;

@end

@implementation GKContactViewController
@synthesize UserID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"通讯录";

        self.filteredArray = [NSMutableArray arrayWithCapacity:0];
        self.sectionDic = [NSMutableDictionary dictionaryWithCapacity:0];
        self.phoneDic = [NSMutableDictionary dictionaryWithCapacity:0];
        self.contactDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"通讯录";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    GK_RELEASE(addButton);
    
    
    [self loadContacts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.sectionDic = nil;
    self.phoneDic = nil;
    self.contactDic = nil;
    self.filteredArray = nil;
    GK_SUPER_DEALLOC();
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self.searchDisplayController isActive]) {
        [self loadContacts];
        [self.tableView reloadData];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
	NSComparisonResult result = [contactName compare:searchT
                                             options:NSCaseInsensitiveSearch
                                               range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
    return NO;
}

- (void)loadContacts
{

    [self.sectionDic removeAllObjects];
    [self.phoneDic removeAllObjects];
    [self.contactDic removeAllObjects];
    for (int i = 0; i < 26; i++) [self.sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'A'+i]];
    [self.sectionDic setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%c",'#']];
    
    

    ABAddressBookRef addressBook =nil;
    __block BOOL accessGranted = NO;
//    if (ABAddressBookRequestAccessWithCompletion==NULL) {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        }
        else
        {
            addressBook = ABAddressBookCreate();
            accessGranted = YES;
        }
    if (accessGranted) {
        

        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                            CFArrayGetCount(results),
                                                            results);
        //将结果按照拼音排序，将结果放入mresults数组中
        CFArraySortValues(mresults,
                          CFRangeMake(0, CFArrayGetCount(results)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          (void*) ABPersonGetSortOrdering());
        //遍历所有联系人
        for (int k=0;k<CFArrayGetCount(mresults);k++) {
            ABRecordRef record=CFArrayGetValueAtIndex(mresults,k);
            NSString *personname = (__bridge NSString *)ABRecordCopyCompositeName(record);
            ABMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
            ABRecordID recordID=ABRecordGetRecordID(record);
            for (int k = 0; k<ABMultiValueGetCount(phone); k++)
            {
                NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                NSRange range=NSMakeRange(0,3);
                NSString *str=[personPhone substringWithRange:range];
                if ([str isEqualToString:@"+86"]) {
                    personPhone=[personPhone substringFromIndex:3];
                }
                
                [self.phoneDic setObject:(__bridge id)record forKey:[NSString stringWithFormat:@"%@%d",personPhone,recordID]];
                

            }
            char first=pinyinFirstLetter([personname characterAtIndex:0]);
            NSString *sectionName;
            if ((first>='a'&&first<='z')||(first>='A'&&first<='Z')) {
                if([self searchResult:personname searchText:@"曾"])
                    sectionName = @"Z";
                else if([self searchResult:personname searchText:@"解"])
                    sectionName = @"X";
                else if([self searchResult:personname searchText:@"仇"])
                    sectionName = @"Q";
                else if([self searchResult:personname searchText:@"朴"])
                    sectionName = @"P";
                else if([self searchResult:personname searchText:@"查"])
                    sectionName = @"Z";
                else if([self searchResult:personname searchText:@"能"])
                    sectionName = @"N";
                else if([self searchResult:personname searchText:@"乐"])
                    sectionName = @"Y";
                else if([self searchResult:personname searchText:@"单"])
                    sectionName = @"S";
                else
                    sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([personname characterAtIndex:0])] uppercaseString];
            }
            else {
                sectionName=[[NSString stringWithFormat:@"%c",'#'] uppercaseString];
            }
            
            [[self.sectionDic objectForKey:sectionName] addObject:(__bridge id)record];
            [self.contactDic setObject:(__bridge id)record forKey:[NSNumber numberWithInt:recordID]];
        }
   
    }else
    {
        
    }
    }

//新建联系人
- (void)insertNewObject:(id)sender
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    navigation.navigationBar.barStyle = UIBarStyleBlack;
	[self presentModalViewController:navigation animated:YES];
    
	
    GK_RELEASE(picker);
    GK_RELEASE(navigation);
}

#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    ABPropertyType type = ABPersonGetTypeOfProperty(property);
    switch (type) {
        case kABStringPropertyType: {
            NSString *value = (__bridge  NSString *)ABRecordCopyValue(person, property);
            NSLog(@"property value = %@", value);
            GK_RELEASE(value);
            break;
        }
        case kABMultiStringPropertyType: {
            ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
            CFIndex index = ABMultiValueGetIndexForIdentifier(multi, identifierForValue);
            CFStringRef value = ABMultiValueCopyValueAtIndex(multi, index);

            UserID = (__bridge NSString*)(value);
            CFRelease(multi);
            CFRelease(value);
            break;
        }
        default:
            break;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"拨号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"呼叫联系人" otherButtonTitles:@"编辑联系人", nil];
    sheet.destructiveButtonIndex =-1;

    [sheet showFromTabBar:self.tabBarController.tabBar];
    
    GK_RELEASE(sheet);
    return NO;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
        
    if (buttonIndex == 0) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"呼叫" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        view.tag=100;
        [view show];
        GK_RELEASE(view);
    }else if(buttonIndex == 1)
        {
            NSString *string = [NSString stringWithFormat:@"号码前是否加0"];
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"编辑联系人" message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            view.tag = 200;
            [view show];
            GK_RELEASE(view);
        }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==100) {

        if (buttonIndex==1) {

        
        [GKAppDelegate makeCall:UserID];
        }
    }else if(alertView.tag ==200)
    {
        if (buttonIndex ==1) {
            GKAppDelegate.tabViewController.selectedIndex = 2;

            
            NSMutableString *string = [[NSMutableString alloc] initWithCapacity:0];
            NSRange range=NSMakeRange(0,3);
            NSString *str=[UserID substringWithRange:range];
            
            NSLog(@"%@",string);
            if ([str isEqualToString:@"+86"]) {
                [string appendString:@"0"];
                [string appendString:[UserID substringFromIndex:3]];
            }else{
                [string appendString:UserID];
            }

            NSDictionary *dict = [NSDictionary dictionaryWithObject:string forKey:@"userID"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"eit" object:self userInfo:dict];
        }
    }
}
#pragma mark - Table view data source
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView])
    {
        NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        for (int i = 0; i < 27; i++)
        {
            [indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
        }
        return indices;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title == UITableViewIndexSearch)
	{
		[self.tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
		return -1;
	}
    
    return  [ALPHA rangeOfString:title].location;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return 27;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:section]];
        return  [[self.sectionDic objectForKey:key] count];
    }
    return [self.filteredArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView])
    {
        return nil;
    }
    
    NSString *key = [NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:section]];
    if ([[self.sectionDic objectForKey:key] count] !=0 )
    {
        return key;
    }
    return nil;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tableView isEqual:self.tableView]) {
        //搜索结果
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            GK_AUTORELEASE(cell);
        }
        NSDictionary *person = [self.filteredArray objectAtIndex:indexPath.row];
        cell.textLabel.text=[person objectForKey:@"name"];
        cell.detailTextLabel.text=[person objectForKey:@"phone"];
    }
    else {
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            GK_AUTORELEASE(cell);
        }
        NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:indexPath.section]];
        NSMutableArray *persons = [self.sectionDic objectForKey:key];
        ABRecordRef record = (__bridge ABRecordRef)[persons objectAtIndex:indexPath.row];
        cell.textLabel.text =(__bridge NSString *)ABRecordCopyCompositeName(record);
    
        //        NSData *imageData=(NSData*)ABPersonCopyImageData(record);
        //
        //        [cell.imageView setImage:[UIImage imageWithData:imageData]];
        //         cell.imageView.contentMode=UIViewContentModeScaleToFill;
    }
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    ABRecordRef person;
    if (![tableView isEqual:self.tableView]) {
        NSMutableDictionary *record=[self.filteredArray objectAtIndex:indexPath.row];
        NSString *recordID=[record objectForKey:@"ID"];
        person = (__bridge ABRecordRef)[self.contactDic objectForKey:recordID];
        
        
    }
    else {
        NSString *key=[NSString stringWithFormat:@"%c",[ALPHA characterAtIndex:indexPath.section]];
        NSMutableArray *persons=[self.sectionDic objectForKey:key];
        person = (__bridge ABRecordRef)[persons objectAtIndex:indexPath.row];
    }
    ABPersonViewController *picker = [[ABPersonViewController alloc] init];
    GK_AUTORELEASE(picker);

    
    picker.displayedPerson = person;
    picker.allowsActions=YES;
    picker.allowsEditing = YES;
    // Allow users to edit the person’s information

    
    picker.personViewDelegate = self;
    [self.navigationController pushViewController:picker animated:YES];
    
}

#pragma UISearchDisplayDelegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self performSelectorOnMainThread:@selector(searchWithString:) withObject:searchString waitUntilDone:YES];
    
    return YES;
}
-(void)searchWithString:(NSString *)searchString
{
    [self.filteredArray removeAllObjects];
    NSString * regex        = @"(^[0-9]+$)";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([searchString length]!=0) {
        if ([pred evaluateWithObject:searchString]) { //判断是否是数字
            NSArray *phones=[self.phoneDic allKeys];
            for (NSString *phone in phones) {
                if ([self searchResult:phone searchText:searchString]) {
                    ABRecordRef person = (__bridge ABRecordRef)[self.phoneDic objectForKey:phone];
                    ABRecordID recordID=ABRecordGetRecordID(person);
                    NSString *ff=[NSString stringWithFormat:@"%d",recordID];
                    
                    NSString *name=(__bridge NSString *)ABRecordCopyCompositeName(person);
                    NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                    [record setObject:name forKey:@"name"];
                    [record setObject:[phone substringToIndex:(phone.length-ff.length)] forKey:@"phone"];
                    [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                    [self.filteredArray addObject:record];
                    GK_RELEASE(record);
                    //NSLog(@"%@",filteredArray);
                }
            }
        }
        else {
            //搜索对应分类下的数组
            NSString *sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([searchString characterAtIndex:0])] uppercaseString];
            NSArray *array=[self.sectionDic objectForKey:sectionName];
            for (int j=0;j<[array count];j++) {
                ABRecordRef person=(__bridge ABRecordRef)[array objectAtIndex:j];
                NSString *name=(__bridge NSString *)ABRecordCopyCompositeName(person);
                if ([self searchResult:name searchText:searchString]) { //先按输入的内容搜索
                    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
                    ABRecordID recordID=ABRecordGetRecordID(person);
                    NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                    [record setObject:name forKey:@"name"];
                    [record setObject:personPhone forKey:@"phone"];
                    [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                    [self.filteredArray addObject:record];
                    GK_RELEASE(record);
                }
                else { //按拼音搜索
                    NSString *string = @"";
                    NSString *firststring=@"";
                    for (int i = 0; i < [name length]; i++)
                    {
                        if([string length] < 1)
                            string = [NSString stringWithFormat:@"%@",
                                      [POAPinyin quickConvert:[name substringWithRange:NSMakeRange(i,1)]]];
                        else
                            string = [NSString stringWithFormat:@"%@%@",string,
                                      [POAPinyin quickConvert:[name substringWithRange:NSMakeRange(i,1)]]];
                        if([firststring length] < 1)
                            firststring = [NSString stringWithFormat:@"%c",
                                           pinyinFirstLetter([name characterAtIndex:i])];
                        else
                        {
                            if ([name characterAtIndex:i]!=' ') {
                                firststring = [NSString stringWithFormat:@"%@%c",firststring,
                                               pinyinFirstLetter([name characterAtIndex:i])];
                            }
                            
                        }
                    }
                    if ([self searchResult:string searchText:searchString]
                        ||[self searchResult:firststring searchText:searchString])
                    {
                        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
                        NSString * personPhone = (__bridge  NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
                        ABRecordID recordID=ABRecordGetRecordID(person);
                        NSMutableDictionary *record=[[NSMutableDictionary alloc] init];
                        [record setObject:name forKey:@"name"];
                        [record setObject:personPhone forKey:@"phone"];
                        [record setObject:[NSNumber numberWithInt:recordID] forKey:@"ID"];
                        [self.filteredArray addObject:record];
                        GK_RELEASE(record);
                        
                    }
                    
                    
                }
            }
        }
    }
}
-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
