//
//  FriendsTableViewController.h
//  KavaTask
//
//  Created by roko on 20.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate>

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (assign, nonatomic) BOOL didLoadFriends;

@property (strong, nonatomic) NSString *nextRequest;

@property (strong, nonatomic) UIPickerView *priorityPicker;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@property (weak, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSString *textOnStartEditing;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void) requestNextFriendBatch:(NSString*)parameters;

@end
