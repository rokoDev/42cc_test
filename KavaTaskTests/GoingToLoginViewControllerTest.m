//
//  GoingToLoginViewControllerTest.m
//  KavaTask
//
//  Created by roko on 18.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "GoingToLoginViewControllerTest.h"

#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import "GoingToLoginViewController.h"

@implementation GoingToLoginViewControllerTest

- (void)testThat_GoingToLoginViewController_IsNotNil
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    GoingToLoginViewController *goinToLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"GoingToLoginVC"];
    STAssertNotNil(goinToLoginVC, @"GoingToLoginViewController is nil!");
}

- (void)testLoginedViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    GoingToLoginViewController *goinToLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"GoingToLoginVC"];
    [goinToLoginVC view];
    
    STAssertNotNil([goinToLoginVC activityIndicator], @"activityIndicator should not be nil");
    STAssertNotNil([goinToLoginVC loginBtn], @"loginBtn should not be nil");
    
    //button test
    id vcMock = [OCMockObject partialMockForObject:goinToLoginVC];
    
    [[vcMock expect] loginBtnTapped:goinToLoginVC.loginBtn];
    
    [goinToLoginVC.loginBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [vcMock verify];
}

@end
