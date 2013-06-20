//
//  TabControllerTest.m
//  KavaTask
//
//  Created by roko on 20.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "TabControllerTest.h"
#import <OCMock/OCMock.h>
#import "AppDelegate.h"
#import "AboutMeViewController.h"
#import "LoginedViewControllerTest.h"

@implementation TabControllerTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testThat_TabBarController_IsWorkingAndDontLeadToCrash
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UIViewController *tabBarVC = [storyboard instantiateInitialViewController];
    
    STAssertNotNil(tabBarVC, @"tabBarVC is nil!");
    STAssertTrue([tabBarVC isKindOfClass:[UITabBarController class]], @"initial view controller must be instance of the UITabBarController");
    [tabBarVC view];
    
    STAssertTrue((2 == [[[(UITabBarController *)tabBarVC tabBar] items] count]), @"tabBarVC must have two tabs");
    
    [(UITabBarController *)tabBarVC setSelectedIndex:0];
    
    UIViewController *initialTab = [(UITabBarController *)tabBarVC selectedViewController];
    STAssertTrue([initialTab isKindOfClass:[UINavigationController class]], @"initial tab must be instance of the UINavigationController class");
    
    [(UITabBarController *)tabBarVC setSelectedIndex:1];
    
    UIViewController *aboutTab = [(UITabBarController *)tabBarVC selectedViewController];
    //NSLog(@"aboutTab class name: %@" [[aboutTab class]);
    NSString *str = [NSString stringWithFormat:@"%@", [[aboutTab class] description]];
    NSLog(@"%@", str);
    STAssertTrue([str isEqualToString:@"AboutMeViewController"], @"second tab must be instance of the AboutMeViewController class");
}

@end
