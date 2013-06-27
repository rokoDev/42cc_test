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

static NSString *CellIdentifier = @"Cell";

const int friendsCountLimit = 8;

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
                                          
                                          [_friendList addObject:friendDict];
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
    }
    //NSLog(@"row = %i", indexPath.row);
    
    
    
    if (indexPath.row < [self.friendList count]) {
        NSDictionary *friend = [self.friendList objectAtIndex:indexPath.row];
        
        cell.userID = friend[@"id"];
        cell.userLink = friend[@"link"];
        
        NSString *str = [NSString stringWithFormat:@"%@ %@", friend[@"first_name"], friend[@"last_name"]];
        cell.userName.text = str;
        
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
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        // Facebook app is installed
        NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", [userCell userID]]];
        [[UIApplication sharedApplication] openURL:urlApp];
    }
    else {
        NSURL *url = [NSURL URLWithString:[userCell userLink]];
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

@end
