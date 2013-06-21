//
//  FriendsTableViewController.h
//  KavaTask
//
//  Created by roko on 20.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (assign, nonatomic) BOOL didLoadFriends;

@property (strong, nonatomic) NSString *nextRequest;

- (void) requestNextFriendBatch:(NSString*)parameters;

@end