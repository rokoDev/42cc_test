//
//  FriendsTableViewController.m
//  KavaTask
//
//  Created by roko on 20.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "AppDelegate.h"
#import "CustomTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DateField.h"

static NSString *CellIdentifier = @"Cell";

const int friendsCountLimit = 8;

const int defaultPriority = 1;//default user priority

const NSInteger componentCount = 4;//count components in picker view

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

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
    
    self.friendList = [NSMutableArray new];
    
    self.priorityPicker = [UIPickerView new];
    
    //localePicker.frame = CGRectMake(0, 0, 320, 120);
    self.priorityPicker.showsSelectionIndicator = YES;
    self.priorityPicker.delegate = self;
    
    [self createInputAccessoryView];
    
    // Register Class for Cell Reuse Identifier
    //[self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    //@"friends.limit(3).fields(last_name,picture.width(75).height(75),first_name,link)";
    self.nextRequest = @"friends.fields(last_name,picture.width(75).height(75),first_name,link)";
    //self.nextRequest = [NSString stringWithFormat:@"friends.limit(%i).fields(last_name,picture.width(75).height(75),first_name,link)", friendsCountLimit];
    
    self.didLoadFriends = YES;
    
    [self requestNextFriendBatch:self.nextRequest];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestNextFriendBatch:(NSString *)parameters
{
    //parameters = @"friends.limit(3).fields(last_name,picture.width(75).height(75),first_name,link)"
    //NSLog(@"requestNextFriendBatch = %@", parameters);
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection startWithGraphPath:@"me"
                                     parameters:[NSDictionary dictionaryWithObject:parameters forKey:@"fields"]
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if(!error) {
                                      NSArray *data = result[@"friends"][@"data"];
                                      int i = 0;
                                      for (FBGraphObject<FBGraphUser> *friend in data) {
                                          NSMutableDictionary *friendDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                             friend[@"first_name"], @"first_name",
                                                                             friend[@"last_name"], @"last_name",
                                                                             friend[@"picture"][@"data"][@"url"], @"url",
                                                                             friend[@"id"], @"id",
                                                                             friend[@"link"], @"link", nil];
                                          [friendDict setObject:[NSNumber numberWithInt:defaultPriority] forKey:@"priority"];
                                          
                                          NSComparator comparator = ^(NSDictionary *obj1, NSDictionary *obj2) {
                                              NSNumber * val1 = (NSNumber*)[obj1 objectForKey:@"priority"];
                                              NSNumber * val2 = (NSNumber*)[obj1 objectForKey:@"priority"];
                                              return [val1 compare:val2];
                                          };
                                          NSUInteger newIndex = [_friendList indexOfObject:friendDict
                                                                       inSortedRange:(NSRange){0, [_friendList count]}
                                                                             options:NSBinarySearchingInsertionIndex
                                                                     usingComparator:comparator];
                                          
                                          [_friendList insertObject:friendDict atIndex:newIndex];
                                          
                                          //[_friendList addObject:friendDict];
                                          ++i;
                                      }
                                      if (i == friendsCountLimit) {
                                          self.nextRequest = result[@"friends"][@"paging"][@"next"];
                                      }
                                      else
                                          self.nextRequest = nil;
                                      
                                      [self.tableView reloadData];
                                  }
                                  else {
                                      [(AppDelegate*)[[UIApplication sharedApplication] delegate] showErrorAlert:error];
                                  }
                              }];
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
    //NSLog(@"numberOfRowsInSection = %i",[_friendList count]);
    return [_friendList count];
    NSInteger friendsCount = [_friendList count];
    if (friendsCount>0)
        ++friendsCount;
    return friendsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (nil == cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
//        cell.priorityField.enableCut = NO;
//        cell.priorityField.enablePaste = NO;
//        cell.priorityField.inputView = self.priorityPicker;
//        cell.priorityField.inputAccessoryView = self.keyboardToolbar;
    }
    
    cell.priorityField.inputView = self.priorityPicker;
    cell.priorityField.inputAccessoryView = self.keyboardToolbar;
    cell.priorityField.delegate = self;
    //NSLog(@"row = %i", indexPath.row);
    
    
    
    
    if (indexPath.row < [self.friendList count]) {
        NSMutableDictionary *friend = [self.friendList objectAtIndex:indexPath.row];
        
        //cell.userID = friend[@"id"];
        //cell.userLink = friend[@"link"];
        
        cell.infoDict = friend;
        
        NSString *str = [NSString stringWithFormat:@"%@ %@", friend[@"first_name"], friend[@"last_name"]];
        cell.userName.text = str;
        
        cell.priorityField.text = [(NSNumber*)friend[@"priority"] stringValue];
        
        [cell.userPhoto setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"url"]] placeholderImage:[CustomTableViewCell defaultPhoto]];
    }
    else {
        cell.userName.text = @"More results";
        if (self.nextRequest) {
            [self requestNextFriendBatch:self.nextRequest];
        }
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    CustomTableViewCell *userCell = (CustomTableViewCell*)[self.friendTableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *infoDict = [userCell infoDict];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        // Facebook app is installed
        NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", infoDict[@"id"]]];
        [[UIApplication sharedApplication] openURL:urlApp];
    }
    else {
        NSURL *url = [NSURL URLWithString:infoDict[@"link"]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"willDisplayCell");
//    if ((indexPath.row >= [_friendList count]-1)&&(self.nextRequest)) {
//        [self requestNextFriendBatch:self.nextRequest];
//    }
}

#pragma mark UITextFieldDelegate' methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"text begin editing");
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    NSMutableArray *stringBuffer = [NSMutableArray arrayWithCapacity:[textField.text length]];
    for (int i = 0; i < [textField.text length]; i++) {
        [stringBuffer addObject:[NSString stringWithFormat:@"%C", [textField.text characterAtIndex:i]]];
    }
    int curComponent = 0;
    for (NSString *val in stringBuffer) {
        [self.priorityPicker selectRow:[val integerValue]-1 inComponent:curComponent++ animated:YES];
    }
    for (; curComponent < componentCount; curComponent++) {
        [self.priorityPicker selectRow:10 inComponent:curComponent animated:YES];
    }
    
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id cell =[[self.activeField superview] superview];
    NSLog(@"cell class = %@", [[cell class] description]);
    
    NSMutableDictionary *friendDict = [(CustomTableViewCell*)cell infoDict];
    [friendDict setObject:[NSNumber numberWithInteger:[textField.text integerValue]] forKey:@"priority"];
    [_friendList removeObject:friendDict];
    
    NSComparator comparator = ^(NSDictionary *obj1, NSDictionary *obj2) {
        NSNumber * val1 = (NSNumber*)[obj1 objectForKey:@"priority"];
        NSNumber * val2 = (NSNumber*)[obj1 objectForKey:@"priority"];
        return [val1 compare:val2];
    };
    NSUInteger newIndex = [_friendList indexOfObject:friendDict
                                       inSortedRange:(NSRange){0, [_friendList count]}
                                             options:NSBinarySearchingInsertionIndex
                                     usingComparator:comparator];
    
    [_friendList insertObject:friendDict atIndex:newIndex];
    [self.tableView reloadData];
    self.activeField = nil;
}


#pragma mark UIPickerView delegate methods



- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSLog(@"didSelectRow");
    if (self.activeField) {
        NSMutableString *newPriorityStr = [NSMutableString new];
        for (int i = 0; i < componentCount; i++) {
            NSInteger selRow = [pickerView selectedRowInComponent:i];
            if (10 == selRow) {
                break;
            }
            else {
                if (!i)
                    ++selRow;
                [newPriorityStr appendString:[NSString stringWithFormat:@"%i",selRow]];
            }
        }
        if ([newPriorityStr length]) {
            self.activeField.text = newPriorityStr;
        }
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 9;
    if (component > 0)
        numberOfRows+=2;//rows for ' ' and '0'
    return numberOfRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return componentCount;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger titleNumber = row;
    if (!component)
        ++titleNumber;
    NSMutableString *title;
    if (10 == titleNumber) {
        title = [NSMutableString stringWithString:@""];
    }
    else
        title = [NSMutableString stringWithString:[[NSNumber numberWithInteger:titleNumber] stringValue]];
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return ([[UIScreen mainScreen] bounds].size.width-50.0f)/componentCount;
}

#pragma mark InputAccessoryView
- (void)createInputAccessoryView
{
    self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTabBarHeight)];
    self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    self.keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTyping:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexSpace, doneButton, nil] animated:NO];
}

- (void)doneTyping:(id)sender
{
    NSLog(@"doneTyping");
    
    [self.activeField resignFirstResponder];
    
//    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
//    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
//        if (view.isFirstResponder) {
//            [view resignFirstResponder];
//            *stop = YES;
//        }
//    }];
}

@end
