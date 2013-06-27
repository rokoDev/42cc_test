//
//  GoingToLoginViewController.m
//  Ticket2
//
//  Created by roko on 05.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "GoingToLoginViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface GoingToLoginViewController ()
{
    Reachability *internetReachableFoo;
}
@end



@implementation GoingToLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"init GoingToLoginViewController");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"viewDidLoad: GoingToLoginViewController");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnTapped:(id)sender {
    NSLog(@"loginBtnTapped");
    
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    __weak typeof(self) weakSelf = self;
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [weakSelf.activityIndicator startAnimating];
            //[_activityIndicator startAnimating];
            
            [appDelegate openSession];
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"Error", @"Error")
                                      message:NSLocalizedString(@"There is no internet connection. You should find one.", @"There is no internet connection. You should find one.")
                                      delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                      otherButtonTitles:nil];
            [alertView show];
        });
    };
    
    [internetReachableFoo startNotifier];
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    if ([appDelegate doesInternetConnectionExists]) {
//        NSLog(@"internet connection exists");
//        [self.activityIndicator startAnimating];
//        
//        [appDelegate openSession];
//        
//        // The person using the app has initiated a login, so call the openSession method
//        // and show the login UX if necessary.
//        //[appDelegate openSessionWithAllowLoginUI:YES];
//    }
//    else {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:NSLocalizedString(@"Error", @"Error")
//                                  message:NSLocalizedString(@"There is no internet connection. You should find one.", @"There is no internet connection. You should find one.")
//                                  delegate:nil
//                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
}

- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self.activityIndicator stopAnimating];
}
@end
