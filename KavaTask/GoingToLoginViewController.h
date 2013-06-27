//
//  GoingToLoginViewController.h
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoingToLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)loginBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (void)loginFailed;

@end
