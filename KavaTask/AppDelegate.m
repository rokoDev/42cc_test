//
//  AppDelegate.m
//  KavaTask
//
//  Created by roko on 13.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AppDelegate.h"

NSString *const AboutMeDatabaseFileName = @"aboutMeDatabase.db";
NSString *const AboutMeTableName        = @"aboutMeTable";
NSString *const KeyField                = @"id";
NSString *const PhotoField              = @"photo";
NSString *const InfoField               = @"info";
NSString *const MyIdInDatabase          = @"me";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

#pragma mark - Full path for a file in document directory

- (NSString *)getFullPathForFileInDocDir:(NSString*)fileName
{
    return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
}

#pragma mark - Show alert with error message

- (void)showErrorAlert:(NSError *)error
{
    if (!error)
        return;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"Error")
                              message:error.localizedDescription
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                              otherButtonTitles:nil];
    [alertView show];
}

@end
