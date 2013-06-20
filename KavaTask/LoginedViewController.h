//
//  LoginedViewController.h
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "RXMLElement.h"

@interface LoginedViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIButton *logoutBtn;

- (void)logoutBtnTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) NSMutableDictionary *userInfo;
@property (strong, nonatomic) NSMutableDictionary *namesOfTheTextFields;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) UIToolbar *keyboardToolbarForUpdatedTime;

@property (weak, nonatomic) UITextField *activeField;
@property (assign, nonatomic) float keyboardHeight;
@property (strong, nonatomic) NSDictionary *localesDict;
@property (strong, nonatomic) NSArray *sortedLocalesArray;


- (void)setDefaultUserData;
- (void)placeUI;
- (void)saveToDatabase:(NSString*)databaseFileName;
- (BOOL)loadDataFromDatabase:(NSString*)databaseFileName;
- (void)sessionStateChanged:(NSNotification*)notification;
- (void)ensureImageViewContentMode;

- (void)textFieldDoneEditing:(id)sender;
- (void)birthdayPickerValChanged:(id)sender;
- (void)updatedTimePickerValChanged:(id)sender;

@end
