//
//  LoginedViewControllerTest.m
//  KavaTask
//
//  Created by roko on 18.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginedViewControllerTest.h"
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import "LoginedViewController.h"

@implementation LoginedViewControllerTest

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

- (void)testThat_LoginedViewController_IsNotNil
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginedViewController *loginedVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginedVC"];
    STAssertNotNil(loginedVC, @"LoginedViewController is nil!");
}

- (void)testExistenceOfDefaultImageInFacebookSDKResources_bundle
{
    UIImage *defaultUserImage = [UIImage imageNamed:DefaultUserImagePath];
    STAssertNotNil(defaultUserImage, [NSString stringWithFormat:@"file at path:%@ not found", DefaultUserImagePath]);
}

- (void)testLoginedViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginedViewController *loginedVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginedVC"];
    [loginedVC view];
    
    STAssertNotNil([loginedVC scrollView], @"scrollView should not be nil");
    STAssertNotNil([loginedVC imageView], @"imageView should not be nil");
    STAssertNotNil([loginedVC logoutBtn], @"logoutBtn should not be nil");
    
    //button test
    id vcMock = [OCMockObject partialMockForObject:loginedVC];
    
    [[vcMock expect] logoutBtnTapped:loginedVC.logoutBtn];
    
    [loginedVC.logoutBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [vcMock verify];
}

@end
