//
//  KavaTaskTests.m
//  KavaTaskTests
//
//  Created by roko on 13.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "KavaTaskTests.h"
#import <OCMock/OCMock.h>
#import "AboutMeViewController.h"
#import <UIKit/UIKit.h>

@implementation KavaTaskTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    self.appDelegate = [[AppDelegate alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    self.appDelegate = nil;
    
    [super tearDown];
}

- (void)testExample
{
    //STFail(@"Unit tests are not implemented yet in KavaTaskTests");
}

- (void)testAppDelegateInstantiates
{
    STAssertNotNil(self.appDelegate, @"AppDelegate instantiate failed!");
}

- (void)testThat_AboutMeViewController_IsNotNil
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AboutMeViewController *aboutMeVC = [storyboard instantiateViewControllerWithIdentifier:@"AboutMeViewController"];
    STAssertNotNil(aboutMeVC, @"aboutMeVC is nil!");
}

- (void)testAboutMeViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AboutMeViewController *aboutMeVC = [storyboard instantiateViewControllerWithIdentifier:@"AboutMeViewController"];
    [aboutMeVC view];
    
    STAssertNotNil([aboutMeVC scrollView], @"scrollView should not be nil");
    STAssertNotNil([aboutMeVC imageView], @"imageView should not be nil");
    
    STAssertNotNil([aboutMeVC mainView], @"mainView should not be nil");
    
    STAssertNotNil([[aboutMeVC imageView] image], @"UIImage is nil!");
    STAssertEquals([[aboutMeVC imageView] image].size.height , [[aboutMeVC imageView] image].size.width, @"image must be square");
    STAssertEquals([[aboutMeVC imageView] image].size.height, 128.0f, @"image side length must be 128");
    
    STAssertEqualObjects([aboutMeVC mainView], [[aboutMeVC scrollView] superview], @"scrollView must be subview of mainView");
    
    STAssertEqualObjects([aboutMeVC scrollView], [[aboutMeVC imageView] superview], @"imageView must be subview of scrollView");
    
}

@end
