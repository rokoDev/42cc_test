//
//  LoginedViewController.h
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginedViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)logoutBtnTapped:(id)sender;

@property (strong, nonatomic) NSDictionary *userInfo;

- (void)setDefaultUserData;
- (void)placeUI;
- (void)saveToDatabase:(NSString*)databaseFileName;
- (BOOL)loadDataFromDatabase:(NSString*)databaseFileName;
- (void)sessionStateChanged:(NSNotification*)notification;
- (void)ensureImageViewContentMode;

@end
