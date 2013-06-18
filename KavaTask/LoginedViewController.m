//
//  LoginedViewController.m
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "LoginedViewController.h"
#import "AppDelegate.h"

#ifndef makeString
#define makeString(x,y) (((x) == (nil)) ? (y) : (x))
#endif  // makeString

@interface LoginedViewController ()

@end

@implementation LoginedViewController

- (void)dealloc
{
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
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}

- (void)viewDidLoad
{
    NSLog(@"LoginedViewController: viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)logoutBtnTapped:(id)sender {
    NSLog(@"logoutBtnTapped");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *userAccessToken = FBSession.activeSession.accessTokenData.accessToken;
    NSDictionary *deletingInfo = @{DBFileNameKey: AboutMeDatabaseFileName,
                                   KeyField: userAccessToken};
    [appDelegate deleteFromDatabase:deletingInfo];
    //[appDelegate deleteRowForKey:FBSession.activeSession.accessTokenData.accessToken];
    
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        if ([self loadDataFromDatabase:AboutMeDatabaseFileName]) {
            [self placeUI];
        }
        else {
            [self setDefaultUserData];
            [self ensureImageViewContentMode];
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:[NSDictionary dictionaryWithObject:@"picture.type(large),id,gender,first_name,last_name,email, birthday,name,username,locale,link,timezone,updated_time,verified"
                                                                                forKey:@"fields"]
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if(!error) {
                                          NSLog(@"%@", result);
                                          
                                          self.userInfo = result;
                                          
                                          //[self saveToDatabase:AboutMeDatabaseFileName];
                                          
                                          NSURL *url = [NSURL URLWithString:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
                                          
                                          
                                          ////////////////////////////////
                                          // Load images async
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                              /* Код, который должен выполниться в фоне */
                                              NSData *imageData = [NSData dataWithContentsOfURL:url];
                                              UIImage *userImage = [UIImage imageWithData:imageData];
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  /* Код, который выполниться в главном потоке */
                                                  self.imageView.image = userImage;
                                                  [self ensureImageViewContentMode];
                                                  
                                                  [self saveToDatabase:AboutMeDatabaseFileName];
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
    
    self.userInfo = nil;
    
    //self.textInfo.text = @"";
}

- (void)placeUI
{
    UIScrollView *sv = self.scrollView;
    
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    
    sv.scrollEnabled = YES;
    sv.alwaysBounceVertical = YES;
    
    
    UIImageView *iv = self.imageView;
    
    
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    UILabel* previousLab = nil;
    for (id key in self.userInfo) {
        UILabel *fieldName = [UILabel new];
        fieldName.translatesAutoresizingMaskIntoConstraints = NO;
        fieldName.text = [NSString stringWithFormat:@"%@:", key];
        [sv addSubview:fieldName];
        [sv addConstraint:[NSLayoutConstraint constraintWithItem:fieldName
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:sv
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1.0
                                                        constant:0]];
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":fieldName}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":fieldName, @"prev":previousLab}]];
        }
        
        UILabel *content = [UILabel new];
        content.translatesAutoresizingMaskIntoConstraints = NO;
        content.text = [self.userInfo objectForKey:key];
        [sv addSubview:content];
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[fieldName]-[lab]"
                                                                   options:0 metrics:nil
                                                                     views:@{@"lab":content,@"fieldName":fieldName}]];
        
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":content}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":content, @"prev":previousLab}]];
        }
        
        previousLab = fieldName;
    }
    
    if (previousLab) {
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lab]-(50)-|"
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
        self.userInfo = [loadingInfo objectForKey:InfoField];
    }
    
    return retVal;
}

@end
