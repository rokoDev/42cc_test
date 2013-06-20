//
//  LoginedViewController.m
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "LoginedViewController.h"
#import "AppDelegate.h"
#import "UIView+LoopThroughAllSubviewsWithBlock.h"
#import "DateField.h"
#import "NSString+Validation.h"

#ifndef makeString
#define makeString(x,y) (((x) == (nil)) ? (y) : (x))
#endif  // makeString

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT

#define kTabBarHeight   44
#define kKeyboardAnimationDuration  0.3f


@interface LoginedViewController ()

@end

@implementation LoginedViewController

- (void)dealloc
{
    NSLog(@"LoginedViewController: dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"LoginedViewController: viewWillAppear");
    [super viewWillAppear:animated];
    
    self.namesOfTheTextFields = [NSMutableDictionary new];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)viewDidLoad
{
    NSLog(@"LoginedViewController: viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self createInputAccessoryView];
    [self createInputAccessoryViewForTimeUpdated];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    fullScreenRect.origin = CGPointZero;
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView = sv;
    [[self mainView] addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *iv  = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView = iv;
    [[self scrollView] addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.logoutBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    [self.logoutBtn addTarget:self action:@selector(logoutBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.logoutBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.logoutBtn];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.localesDict = [ud dictionaryForKey:@"localesDict"];
    self.sortedLocalesArray = [ud arrayForKey:@"sortedLocales"];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
    
    self.activeField = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear: LoginedViewController");
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginedViewControllerNotification object:nil];
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate loginedVCDidAppear];
}

//- (void)viewWillLayoutSubviews
//{
//    NSLog(@"viewWillLayoutSubviews: LoginedViewController");
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate loginedVCDidAppear];
//}

- (void)didReceiveMemoryWarning
{
    //NSLog(@"didRecieveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)logoutBtnTapped:(id)sender {
    NSLog(@"logoutBtnTapped");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *userAccessToken = FBSession.activeSession.accessTokenData.accessToken;
    NSDictionary *deletingInfo = @{DBFileNameKey: FacebookDatabaseName,
                                   KeyField: userAccessToken};
    [appDelegate deleteFromDatabase:deletingInfo];
    //[appDelegate deleteRowForKey:FBSession.activeSession.accessTokenData.accessToken];
    
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)populateUserDetails
{
    [self setDefaultUserData];
    if (FBSession.activeSession.isOpen) {
        if ([self loadDataFromDatabase:FacebookDatabaseName]) {
            [self placeUI];
        }
        else {
//            [self setDefaultUserData];
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:[NSDictionary dictionaryWithObject:@"picture.type(large),id,gender,first_name,last_name,email, birthday,name,username,locale,link,timezone,updated_time,verified"
                                                                                forKey:@"fields"]
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if(!error) {
                                          NSLog(@"%@", result);
                                          
                                          self.userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
                                          
                                          [self saveToDatabase:FacebookDatabaseName];
                                          
                                          NSURL *url = [NSURL URLWithString:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
                                          
                                          ////////////////////////////////
                                          // Load images async
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                              /* Код, который должен выполниться в фоне */
                                              if (!self.localesDict) {
                                                  NSString *localesXML = [NSString stringWithContentsOfURL:[NSURL URLWithString:FacebookLocalesURL] encoding:NSUTF8StringEncoding error:nil];
                                                  RXMLElement *rootXML = [RXMLElement elementFromXMLString:localesXML encoding:NSUTF8StringEncoding];
                                                  
                                                  NSMutableDictionary *tmpLocaleDict = [NSMutableDictionary dictionaryWithCapacity:128];
                                                  [rootXML iterateWithRootXPath:@"//locale" usingBlock:^(RXMLElement *locale) {
                                                      NSString *region = [locale child:@"englishName"].text;
                                                      NSString *localeStr = [[[[locale child:@"codes"] child:@"code"] child:@"standard"] child:@"representation"].text;
                                                      //NSString *localeStr = [(RXMLElement*)[[locale childrenWithRootXPath:@"//representation"] lastObject] text];
                                                      
                                                      [tmpLocaleDict setObject:region forKey:localeStr];
                                                  }];
                                                  
                                                  self.localesDict = [NSDictionary dictionaryWithDictionary:tmpLocaleDict];
                                                  if (self.localesDict) {
                                                      NSArray *sortedKeys = [[self.localesDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id key1, id key2) {
                                                          return [(NSString*)key1 caseInsensitiveCompare:(NSString*)key2];
                                                      }];
                                                      
                                                      NSMutableArray * tmpSortedLocales = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
                                                      for (NSString *key in sortedKeys) {
                                                          NSDictionary *localeRegionPair = @{key: [self.localesDict objectForKey:key]};
                                                          [tmpSortedLocales addObject:localeRegionPair];
                                                      }
                                                      self.sortedLocalesArray = [NSArray arrayWithArray:tmpSortedLocales];
                                                      
                                                      
                                                      NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                                      [ud setObject:self.localesDict forKey:@"localesDict"];
                                                      [ud setObject:self.sortedLocalesArray forKey:@"sortedLocales"];
                                                      [ud synchronize];
                                                  }
                                              }
                                              
                                              NSData *imageData = [NSData dataWithContentsOfURL:url];
                                              UIImage *userImage = [UIImage imageWithData:imageData];
                                              
                                              self.imageView.image = userImage;
                                              [self ensureImageViewContentMode];
                                              
                                              [self saveToDatabase:FacebookDatabaseName];
                                              
                                              
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  /* Код, который выполниться в главном потоке */
                                                  
                                                  NSLog(@"self.localeDict = %@", self.localesDict);
                                                  [self placeUI];
                                                  
                                              });
                                          });
                                      }
                                      else {
                                          [(AppDelegate*)[[UIApplication sharedApplication] delegate] showErrorAlert:error];
                                      }
                                  }];
        }
    }
    else {
        
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

- (void)ensureImageViewContentMode {
    // Set the image's contentMode such that if the image is larger than the control, we scale it down, preserving aspect
    // ratio.  Otherwise, we center it.  This ensures that we never scale up, and pixellate, the image.
    CGSize viewSize = CGSizeMake(75, 75);
    CGSize imageSize = self.imageView.image.size;
    UIViewContentMode contentMode;
    
    // If both of the view dimensions are larger than the image, we'll center the image to prevent scaling up.
    // Note that unlike in choosing the image size, we *don't* use any Retina-display scaling factor to choose centering
    // vs. filling.  If we were to do so, we'd get profile pics shrinking to fill the the view on non-Retina, but getting
    // centered and clipped on Retina.
    if (viewSize.width > imageSize.width && viewSize.height > imageSize.height) {
        contentMode = UIViewContentModeCenter;
    } else {
        contentMode = UIViewContentModeScaleAspectFit;
    }
    
    self.imageView.contentMode = contentMode;
}

- (void)setDefaultUserData
{
    //NSString *blankImageName = @"FacebookSDKResources.bundle/FBProfilePictureView/images/fb_blank_profile_square.png";
    //[NSString stringWithFormat:@"FacebookSDKResources.bundle/FBProfilePictureView/images/fb_blank_profile_%@.png", 1 ? @"square" : @"portrait"];
    self.imageView.image = [UIImage imageNamed:DefaultUserImagePath];
    [self ensureImageViewContentMode];
    
    self.userInfo = nil;
    
    //self.textInfo.text = @"";
}

- (void)placeUI
{
    [self.namesOfTheTextFields removeAllObjects];
    [self.scrollView removeConstraints:self.scrollView.constraints];
    [self.view removeConstraints:self.view.constraints];
    for (id someSubview in [self.scrollView subviews]) {
        if ([someSubview isKindOfClass:[UITextField class]] || [someSubview isKindOfClass:[UILabel class]])
        {
            [someSubview removeFromSuperview];
        }
    }
    UIScrollView *sv = self.scrollView;
    [sv setContentOffset:CGPointZero];
    NSLog(@"sv = %@", sv);
    
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|"
                                             options:0 metrics:nil
                                               views:@{@"sv":sv}]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sv]|"
                                             options:0 metrics:nil
                                               views:@{@"sv":sv}]];
    
    sv.scrollEnabled = YES;
    sv.alwaysBounceVertical = YES;
    
    UIButton *btn = self.logoutBtn;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[btn]"
                                                               options:0 metrics:nil
                                                                 views:@{@"btn":btn}]];
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[btn]"
                                                               options:0 metrics:nil
                                                                 views:@{@"btn":btn}]];
    
    UIImageView *iv = self.imageView;
    [self ensureImageViewContentMode];
    
    
    
    
    iv.translatesAutoresizingMaskIntoConstraints = NO;
//    [sv addConstraint:[NSLayoutConstraint constraintWithItem:iv
//                                                   attribute:NSLayoutAttributeCenterX
//                                                   relatedBy:NSLayoutRelationEqual
//                                                      toItem:sv
//                                                   attribute:NSLayoutAttributeCenterX
//                                                  multiplier:1.0
//                                                    constant:0]];
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn]-[iv]"
                                                               options:0 metrics:nil
                                                                 views:@{@"iv":iv, @"btn":btn}]];
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[iv]"
                                                               options:0 metrics:nil
                                                                 views:@{@"iv":iv}]];
    
    NSLog(@"%@", self.userInfo);
    
    UILabel* previousLab = nil;
    for (id key in self.userInfo) {
        if (![[self.userInfo objectForKey:key] isKindOfClass:[NSString class]]) {
            NSLog(@"%@ is %@", key, NSStringFromClass([[self.userInfo objectForKey:key] class]));
            continue;
        }
        UILabel *fieldName = [UILabel new];
        fieldName.translatesAutoresizingMaskIntoConstraints = NO;
        fieldName.text = [NSString stringWithFormat:@"%@:", key];
        [sv addSubview:fieldName];

        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[lab]"
                                                                   options:0 metrics:nil
                                                                     views:@{@"lab":fieldName}]];
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iv]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":fieldName, @"iv":iv}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[fieldName]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"fieldName":fieldName, @"prev":previousLab}]];
        }
        DateField *content = [DateField new];
        content.translatesAutoresizingMaskIntoConstraints = NO;
        content.text = [self.userInfo objectForKey:key];
        [content setDelegate:self];
        [content setReturnKeyType:UIReturnKeyDone];
        [content addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [content setInputAccessoryView:self.keyboardToolbar];
        
        [sv addSubview:content];
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[fieldName]-[content]-(>=0)-|"
                                                                   options:0 metrics:nil
                                                                     views:@{@"content":content,@"fieldName":fieldName}]];
        
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iv]-(50)-[content]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"content":content, @"iv":iv}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[content]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"content":content, @"prev":previousLab}]];
        }
        
        NSValue *textFieldVal = [NSValue valueWithNonretainedObject:content];
        [self.namesOfTheTextFields setObject:key forKey:textFieldVal];
        
        SWITCH(key) {
            CASE(@"birthday") {
                UIDatePicker *birthdayPicker = [UIDatePicker new];
                birthdayPicker.datePickerMode = UIDatePickerModeDate;
                [birthdayPicker addTarget:self action:@selector(birthdayPickerValChanged:) forControlEvents:UIControlEventValueChanged];
                content.enableCut = NO;
                content.enablePaste = NO;
                NSDateFormatter *df = [NSDateFormatter new];
                [df setDateFormat:@"MM/dd/yyyy"];
                NSDate *dateFromStr = [df dateFromString:content.text];
                [birthdayPicker setDate:dateFromStr];
                content.inputView = birthdayPicker;
                break;
            }
            CASE(@"email") {
                [content setKeyboardType:UIKeyboardTypeEmailAddress];
                break;
            }
            CASE(@"first_name") {
                [content setKeyboardType:UIKeyboardTypeAlphabet];
                break;
            }
            CASE(@"gender") {
                [content setKeyboardType:UIKeyboardTypeAlphabet];
                break;
            }
            CASE(@"id") {
                [content setKeyboardType:UIKeyboardTypeNumberPad];
                break;
            }
            CASE(@"last_name") {
                [content setKeyboardType:UIKeyboardTypeAlphabet];
                break;
            }
            CASE(@"link") {
                [content setKeyboardType:UIKeyboardTypeURL];
                break;
            }
            CASE(@"locale") {
                UIPickerView *localePicker = [UIPickerView new];
                localePicker.frame = CGRectMake(0, 200, 320, 200);
                localePicker.showsSelectionIndicator = YES;
                localePicker.delegate = self;
                int row = 0;
                for (NSDictionary *localeRegionPair in self.sortedLocalesArray) {
                    NSArray *keys = [localeRegionPair allKeys];
                    NSString *key = [keys lastObject];
                    if ([key isEqualToString:[self.userInfo objectForKey:@"locale"]]) {
                        [localePicker selectRow:row inComponent:0 animated:NO];
                        break;
                    }
                    ++row;
                }
                content.enableCut = NO;
                content.enablePaste = NO;
                content.inputView = localePicker;
                break;
            }
            CASE(@"name") {
                [content setKeyboardType:UIKeyboardTypeAlphabet];
                break;
            }
            CASE(@"updated_time") {
                UIDatePicker *updatedTimePicker = [UIDatePicker new];
                updatedTimePicker.datePickerMode = UIDatePickerModeDate;
                [updatedTimePicker addTarget:self action:@selector(updatedTimePickerValChanged:) forControlEvents:UIControlEventValueChanged];
                content.enableCut = NO;
                content.enablePaste = NO;
                [content setInputAccessoryView:self.keyboardToolbarForUpdatedTime];
                
                NSDateFormatter *sRFC3339DateFormatter = [NSDateFormatter new];
                NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
                [sRFC3339DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSDate *date = [sRFC3339DateFormatter dateFromString:content.text];
                
                [updatedTimePicker setLocale:enUSPOSIXLocale];
                [updatedTimePicker setTimeZone:[sRFC3339DateFormatter timeZone]];
                
                content.inputView = updatedTimePicker;
                [updatedTimePicker setDate:date];
                break;
            }
            CASE(@"username") {
                [content setKeyboardType:UIKeyboardTypeAlphabet];
                break;
            }
            DEFAULT {
                break;
            }
        }
        
        previousLab = fieldName;
    }
    
    if (previousLab) {
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lab]-|"
                                                                   options:0 metrics:nil
                                                                     views:@{@"lab":previousLab}]];
    }

}

- (void)saveToDatabase:(NSString*)databaseFileName
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *userAccessToken = FBSession.activeSession.accessTokenData.accessToken;
    
    NSDictionary *savingInfo = @{DBFileNameKey: databaseFileName,
                                 PhotoField: self.imageView.image,
                                 InfoField: self.userInfo,
                                 KeyField: userAccessToken};
    
    [appDelegate saveToDatabase:savingInfo];
}

- (BOOL)loadDataFromDatabase:(NSString*)databaseFileName
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary *loadingInfo = [NSMutableDictionary new];
    
    [loadingInfo setObject:databaseFileName forKey:DBFileNameKey];
    [loadingInfo setObject:FBSession.activeSession.accessTokenData.accessToken forKey:KeyField];
    
    BOOL retVal = [appDelegate loadDataFromDatabase:loadingInfo];
    
    if (retVal) {
        self.imageView.image = [loadingInfo objectForKey:PhotoField];
        [self ensureImageViewContentMode];
        self.userInfo = [loadingInfo objectForKey:InfoField];
    }
    
    return retVal;
}


#pragma mark InputAccessoryView
- (void)createInputAccessoryView
{
    self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTabBarHeight)];
    self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    self.keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPrevTextfield:)];
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoNextTextfield:)];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTyping:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects: previousButton, nextButton, flexSpace, doneButton, nil] animated:NO];
}

- (void)createInputAccessoryViewForTimeUpdated
{
    self.keyboardToolbarForUpdatedTime = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kTabBarHeight)];
    self.keyboardToolbarForUpdatedTime.barStyle = UIBarStyleBlackTranslucent;
    self.keyboardToolbarForUpdatedTime.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPrevTextfield:)];
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoNextTextfield:)];
    UIBarButtonItem* timeButton = [[UIBarButtonItem alloc] initWithTitle:@"Set Time" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoTimeSetting:)];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTyping:)];
    
    [self.keyboardToolbarForUpdatedTime setItems:[NSArray arrayWithObjects: previousButton, nextButton, flexSpace, timeButton, doneButton, nil] animated:NO];
    
}

- (void)gotoTimeSetting:(id)sender
{
    UIBarButtonItem* timeButton = (UIBarButtonItem*)sender;
    [timeButton setTitle:@"Set Data"];
    [timeButton setAction:@selector(gotoDataSetting:)];
    
    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
    __block UIView *curFirstResponder = nil;
    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            curFirstResponder = view;
            UIDatePicker *updatedTimePicker = (UIDatePicker*)curFirstResponder.inputView;
            updatedTimePicker.datePickerMode = UIDatePickerModeTime;
            *stop = YES;
        }
    }];
}

- (void)gotoDataSetting:(id)sender
{
    UIBarButtonItem* timeButton = (UIBarButtonItem*)sender;
    [timeButton setTitle:@"Set Time"];
    [timeButton setAction:@selector(gotoTimeSetting:)];
    
    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
    __block UIView *curFirstResponder = nil;
    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            curFirstResponder = view;
            UIDatePicker *updatedTimePicker = (UIDatePicker*)curFirstResponder.inputView;
            updatedTimePicker.datePickerMode = UIDatePickerModeDate;
            *stop = YES;
        }
    }];
}

- (void)gotoPrevTextfield:(id)sender
{
    NSLog(@"gotoPrevTextfield");
    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
    __block UIView *curFirstResponder = nil;
    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            curFirstResponder = view;
            *stop = YES;
        }
    }];
    
    if (curFirstResponder) {
        float minDy = MAXFLOAT;
        float lowestY = curFirstResponder.frame.origin.y;
        UITextField *prevTextField = nil;
        UITextField *lowestTextField = nil;
        for (id subview in [self.scrollView subviews]) {
            if ([subview isKindOfClass:[UITextField class]] && !([subview isEqual:curFirstResponder])) {
                UITextField *textField = (UITextField*)subview;
                float dy = curFirstResponder.frame.origin.y - textField.frame.origin.y;
                if ((dy > 0.0f) && (dy < minDy)) {
                    minDy = dy;
                    prevTextField = textField;
                }
                else if ((dy < 0.0f) && (textField.frame.origin.y > lowestY)) {
                    lowestY = textField.frame.origin.y;
                    lowestTextField = textField;
                }
            }
        }
        if (prevTextField) {
            [prevTextField becomeFirstResponder];
            [self moveToNextField:prevTextField];
        }
        else if (lowestTextField) {
            [lowestTextField becomeFirstResponder];
            [self moveToNextField:lowestTextField];
        }
    }
}

- (void)gotoNextTextfield:(id)sender
{
    NSLog(@"gotoNextTextfield");
    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
    __block UIView *curFirstResponder = nil;
    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            curFirstResponder = view;
            *stop = YES;
        }
    }];
    
    if (curFirstResponder) {
        float minDy = MAXFLOAT;
        float uppestY = curFirstResponder.frame.origin.y;
        UITextField *nextTextField = nil;
        UITextField *uppestTextField = nil;
        for (id subview in [self.scrollView subviews]) {
            if ([subview isKindOfClass:[UITextField class]] && !([subview isEqual:curFirstResponder])) {
                UITextField *textField = (UITextField*)subview;
                float dy = textField.frame.origin.y - curFirstResponder.frame.origin.y;
                if ((dy > 0.0f) && (dy < minDy)) {
                    minDy = dy;
                    nextTextField = textField;
                }
                else if ((dy < 0.0f) && (textField.frame.origin.y < uppestY)) {
                    uppestY = textField.frame.origin.y;
                    uppestTextField = textField;
                }
            }
        }
        if (nextTextField) {
            [nextTextField becomeFirstResponder];
            [self moveToNextField:nextTextField];
        }
        else if (uppestTextField) {
            [uppestTextField becomeFirstResponder];
            [self moveToNextField:uppestTextField];
        }
    }
}

- (void)moveToNextField:(UITextField*)nextField
{
    CGRect aRect = self.view.frame;
    aRect.size.height -= self.keyboardHeight;
    CGPoint origin = nextField.frame.origin;
    origin.y -= self.scrollView.contentOffset.y;
    //origin.x -= self.scrollView.contentOffset.x;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(nextField.frame.origin.x-(aRect.size.width)+nextField.frame.size.width, nextField.frame.origin.y-(aRect.size.height));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)doneTyping:(id)sender
{
    NSLog(@"doneTyping");
    
    UIView *myMainView = [[UIApplication sharedApplication] keyWindow];
    [myMainView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            [view resignFirstResponder];
            *stop = YES;
        }
    }];
}

- (void)birthdayPickerValChanged:(id)sender
{
    NSLog(@"birthdayPickerValChanged %@", NSStringFromClass([sender class]));
    
    __block UITextField *birthdayField = nil;
    [self.scrollView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            birthdayField = (UITextField*)view;
            *stop = YES;
        }
    }];
    if (birthdayField) {
        UIDatePicker *datePicker = (UIDatePicker*)sender;
        
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"MM/dd/YYYY"];
        NSDate *newDate = [datePicker date];
        birthdayField.text = [df stringFromDate:newDate];
    }
}

- (void)updatedTimePickerValChanged:(id)sender
{
    NSLog(@"updatedTimePickerValChanged %@", NSStringFromClass([sender class]));
    
    __block UITextField *updatedTimeField = nil;
    [self.scrollView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            updatedTimeField = (UITextField*)view;
            *stop = YES;
        }
    }];
    if (updatedTimeField) {
        UIDatePicker *datePicker = (UIDatePicker*)sender;
        
        NSDateFormatter *sRFC3339DateFormatter = [NSDateFormatter new];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
        [sRFC3339DateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *newDate = [datePicker date];
        updatedTimeField.text = [sRFC3339DateFormatter stringFromDate:newDate];
        
        [self moveToNextField:updatedTimeField];
        
    }
}


#pragma mark Done button

//- (void)addButtonToKeyboard {
//    // create custom button
//    
//    if (doneButton == nil) {
//        doneButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 163, 106, 53)];
//    }
//    else {
//        [doneButton setHidden:NO];
//    }
//    
//    [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    // locate keyboard view
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
//    UIView* keyboard = nil;
//    for(int i=0; i<[tempWindow.subviews count]; i++) {
//        keyboard = [tempWindow.subviews objectAtIndex:i];
//        // keyboard found, add the button
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
//                [keyboard addSubview:doneButton];
//        } else {
//            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
//                [keyboard addSubview:doneButton];
//        }
//    }
//}

- (void)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (void)doneButtonClicked:(id)Sender {
    //Write your code whatever you want to do on done button tap
    //Removing keyboard or something else
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
    
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
    NSValue *textFieldVal = [NSValue valueWithNonretainedObject:textField];
    NSString *fieldName = [self.namesOfTheTextFields objectForKey:textFieldVal];
    
    NSLog(@"%@ did end editing", fieldName);
    
    if (!textField.text || [textField.text isEqualToString:[self.userInfo objectForKey:fieldName]] || ![textField.text length])
    {
        textField.text = [self.userInfo objectForKey:fieldName];
        return;
    }
    
    
    
    SWITCH(fieldName) {
        CASE(@"birthday") {
            [self.userInfo setObject:textField.text forKey:fieldName];
            [self saveToDatabase:FacebookDatabaseName];
            break;
        }
        CASE(@"email") {
            if ([NSString validateEmail:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"first_name") {
            if ([NSString validateAlphabet:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                
                NSString *newName = [NSString stringWithFormat:@"%@ %@", textField.text, [self.userInfo objectForKey:@"last_name"]];
                [self.userInfo setObject:newName forKey:@"name"];
                for (id key in self.namesOfTheTextFields) {
                    if ([[self.namesOfTheTextFields objectForKey:key] isEqualToString:@"name"]) {
                        UITextField *nameField = (UITextField*)[key nonretainedObjectValue];
                        nameField.text = [self.userInfo objectForKey:@"name"];
                        break;
                    }
                }
                
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"gender") {
            if ([NSString validateGender:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"id") {
            if ([NSString validateNumeric:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"last_name") {
            if ([NSString validateAlphabet:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                
                NSString *newName = [NSString stringWithFormat:@"%@ %@", [self.userInfo objectForKey:@"first_name"], textField.text];
                [self.userInfo setObject:newName forKey:@"name"];
                for (id key in self.namesOfTheTextFields) {
                    if ([[self.namesOfTheTextFields objectForKey:key] isEqualToString:@"name"]) {
                        UITextField *nameField = (UITextField*)[key nonretainedObjectValue];
                        nameField.text = [self.userInfo objectForKey:@"name"];
                        break;
                    }
                }
                
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"link") {
            if ([NSString validateURL:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"locale") {
            [self.userInfo setObject:textField.text forKey:fieldName];
            [self saveToDatabase:FacebookDatabaseName];
            break;
        }
        CASE(@"name") {
            NSArray *strings = [textField.text componentsSeparatedByString:@" "];
            BOOL isValidName = YES;
            if (2 != [strings count])
                isValidName = NO;
            else {
                for (NSString *str in strings) {
                    if (![NSString validateAlphabet:str] || ![str length]) {
                        isValidName = NO;
                        break;
                    }
                }
            }
            if (isValidName) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                
                [self.userInfo setObject:[strings objectAtIndex:0] forKey:@"first_name"];
                [self.userInfo setObject:[strings objectAtIndex:1] forKey:@"last_name"];
                
                int entryCount = 0;
                for (id key in self.namesOfTheTextFields) {
                    if ([[self.namesOfTheTextFields objectForKey:key] isEqualToString:@"first_name"]) {
                        UITextField *firstNameField = (UITextField*)[key nonretainedObjectValue];
                        firstNameField.text = [self.userInfo objectForKey:@"first_name"];
                        if (2 == ++entryCount)
                            break;
                    }
                    else if ([[self.namesOfTheTextFields objectForKey:key] isEqualToString:@"last_name"]) {
                        UITextField *lastNameField = (UITextField*)[key nonretainedObjectValue];
                        lastNameField.text = [self.userInfo objectForKey:@"last_name"];
                        if (2 == ++entryCount)
                            break;
                    }
                }
                
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        CASE(@"updated_time") {
            [self.userInfo setObject:textField.text forKey:fieldName];
            [self saveToDatabase:FacebookDatabaseName];
            break;
        }
        CASE(@"username") {
            if ([NSString validateAlphabet:textField.text]) {
                [self.userInfo setObject:textField.text forKey:fieldName];
                [self saveToDatabase:FacebookDatabaseName];
            }
            else {
                textField.text = [self.userInfo objectForKey:fieldName];
            }
            break;
        }
        DEFAULT {
            break;
        }
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    NSLog(@"textFieldShouldReturn");
//    [textField resignFirstResponder];
//    return NO;
//}

#pragma mark Hangling keyboard

- (void)keyboardWillShow:(NSNotification *)n
{
    NSLog(@"keyboardWillShow");
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboardWasShown");
    //1. method
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    kbSize.height -= kTabBarHeight;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height);
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
//    }
    
    //2. method
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    kbSize.height -= kTabBarHeight;
//    CGRect bkgndRect = self.activeField.superview.frame;
//    bkgndRect.size.height += kbSize.height;
//    [self.activeField.superview setFrame:bkgndRect];
//    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height) animated:NO];
    //3. method
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    kbSize.height += kTabBarHeight;
    self.keyboardHeight = kbSize.height;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.activeField.frame.origin;
    origin.y -= self.scrollView.contentOffset.y;
    //origin.x -= self.scrollView.contentOffset.x;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(self.activeField.frame.origin.x-(aRect.size.width)+self.activeField.frame.size.width, self.activeField.frame.origin.y-(aRect.size.height));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark UIPickerView delegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSLog(@"didSelectRow");
    __block UITextField *activeField = nil;
    [self.scrollView loopThroughAllSubviewsWithBlock:^(UIView *view, BOOL *stop) {
        if (view.isFirstResponder) {
            activeField = (UITextField*)view;
            *stop = YES;
        }
    }];
    if (activeField) {
        NSDictionary *localeRegionPair = [self.sortedLocalesArray objectAtIndex:row];
        NSArray *allKeys = [localeRegionPair allKeys];
        NSString *localeStr = [allKeys lastObject];
        activeField.text = localeStr;
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.sortedLocalesArray count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *localeRegionPair = [self.sortedLocalesArray objectAtIndex:row];
    NSArray *allKeys = [localeRegionPair allKeys];
    NSString *key = [allKeys lastObject];
    return [NSString stringWithFormat:@"%@ %@", [localeRegionPair objectForKey:key], key];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return [[UIScreen mainScreen] bounds].size.width;
}

@end
