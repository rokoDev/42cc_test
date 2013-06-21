//
//  AppDelegate.m
//  KavaTask
//
//  Created by roko on 13.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginedViewController.h"
#import "GoingToLoginViewController.h"
#import "FMDatabase.h"

NSString *const AboutMeDatabaseFileName = @"aboutMeDatabase.db";
NSString *const FacebookDatabaseName    = @"facebook.db";
NSString *const AboutMeTableName        = @"aboutMeTable";
NSString *const KeyField                = @"id";
NSString *const PhotoField              = @"photo";
NSString *const InfoField               = @"info";
NSString *const MyIdInDatabase          = @"me";
NSString *const DBFileNameKey           = @"databaseFileName";
NSString *const FacebookLocalesURL      = @"http://www.facebook.com/translations/FacebookLocales.xml";

NSString *const SCSessionStateChangedNotification = @"com.rokoprogs.KavaTask:SCSessionStateChangedNotification";
NSString *const LoginedViewControllerNotification = @"com.rokoprogs.KavaTask:loginedVCDidAppear";
NSString *const DefaultUserImagePath = @"FacebookSDKResources.bundle/FBProfilePictureView/images/fb_blank_profile_square.png";

int const kTabBarHeight                 = 44;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBProfilePictureView class];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginedVCDidAppear) name:LoginedViewControllerNotification object:nil];
    
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
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

- (void)showLoginView
{
    NSLog(@"AppDelegate: showLoginView");
    
    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
    UIViewController *selectedTab = [tabController selectedViewController];
    
    if (![selectedTab isKindOfClass:[UINavigationController class]]) {
        [tabController setSelectedIndex:0];
        selectedTab = [tabController selectedViewController];
    }
    
    UINavigationController *navController = (UINavigationController*)[tabController selectedViewController];
    
    
    UIViewController *topViewController = [navController visibleViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![topViewController isKindOfClass:[GoingToLoginViewController class]]) {
        LoginedViewController *loginedVC = (LoginedViewController*)topViewController;
        [loginedVC performSegueWithIdentifier:@"showGoingToLoginVC" sender:loginedVC];
    } else {
        GoingToLoginViewController *goingToLoginVC = (GoingToLoginViewController*)topViewController;
        [goingToLoginVC loginFailed];
    }
}

- (void)loginedVCDidAppear
{
    NSLog(@"loginedVCDidAppear");
    // See if the app has a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // To-do, show logged in view
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self openSession];
    } else {
        // No, display the login page.
        [self showLoginView];
    }
}

- (void)openSession
{
    NSLog(@"openSession");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_birthday",
                            @"user_location",
                            @"read_friendlists",
                            //@"user_likes",
                            nil];
    [FBSession openActiveSessionWithReadPermissions:permissions//nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSLog(@"sessionStateChanged");
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"sessionStateChanged: FBSessionStateOpen");
            //NSLog(@"access token = %@", session.accessTokenData.accessToken);
            //NSLog(@"access token = %@", FBSession.activeSession.accessTokenData.accessToken);
            UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
            
            UINavigationController *navController = (UINavigationController*)[tabController selectedViewController];
            
            UIViewController *topViewController = [navController visibleViewController];
            
            if ([topViewController isKindOfClass:[GoingToLoginViewController class]])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            // Once the user has logged in, we want them to
            // be looking at the root view.
            
            UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
            
            UINavigationController *navController = (UINavigationController*)[tabController selectedViewController];
            
            [navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
    
    if (error) {
        [self showErrorAlert:error];
    }
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)saveToDatabase:(NSDictionary*)savingInfo
{
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[self getFullPathForFileInDocDir:[savingInfo objectForKey:DBFileNameKey]]];
    
    //open database
    if (![aboutMeDB open]) {
        return;
    }
    
    //create table if it does not exists
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT UNIQUE, '%@' BLOB, '%@' BLOB)", AboutMeTableName, KeyField, PhotoField, InfoField];
    if (![aboutMeDB executeUpdate:sql]) {
        NSError *error = [aboutMeDB lastError];
        NSLog(@"Error: %@ code: %ld", error.localizedDescription, (long)error.code);
        //[self showErrorAlert:error];
        [aboutMeDB close];
        return;
    }
    
    //save data to the database
    sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('%@', '%@', '%@') VALUES (?, ?, ?)", AboutMeTableName, KeyField, PhotoField, InfoField];
    NSData *photoData = UIImagePNGRepresentation((UIImage*)[savingInfo objectForKey:PhotoField]);
    NSData *infoData = [NSPropertyListSerialization dataWithPropertyList:(NSDictionary*)[savingInfo objectForKey:InfoField]
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:NULL];
    if (![aboutMeDB executeUpdate:sql, (NSString*)[savingInfo objectForKey:KeyField], photoData, infoData]) {
        NSError *error = [aboutMeDB lastError];
        NSLog(@"Error: %@ code: %ld", error.localizedDescription, (long)error.code);
        //[self showErrorAlert:error];
        [aboutMeDB close];
        return;
    }
    
    NSLog(@"data has been saved to database");
    
    //close database
    [aboutMeDB close];
}

- (BOOL)loadDataFromDatabase:(NSMutableDictionary*)loadingInfo
{
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[self getFullPathForFileInDocDir:[loadingInfo objectForKey:DBFileNameKey]]];
    
    //open database
    if (![aboutMeDB open]) {
        return NO;
    }
    
    //read database
    NSString* sqliteQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", AboutMeTableName, KeyField, (NSString*)[loadingInfo objectForKey:KeyField]];
    FMResultSet *result = [aboutMeDB executeQuery:sqliteQuery];
    
    if ([result next]) {
        NSData *photoData = [result dataForColumn:PhotoField];
        NSData *infoData = [result dataForColumn:InfoField];
        
        if (!photoData || !infoData) {
            [aboutMeDB close];
            return NO;
        }
        UIImage *userPhoto = [UIImage imageWithData:photoData];
        [loadingInfo setObject:userPhoto forKey:PhotoField];
        
        NSPropertyListFormat plistFormat;
        [loadingInfo setObject:[NSMutableDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListWithData:infoData
                                                                                                                       options:0
                                                                                                                        format:&plistFormat
                                                                                                                         error:NULL]] forKey:InfoField];
        [aboutMeDB close];
        return YES;
    }
    else {
        [aboutMeDB close];
        return NO;
    }
}

- (void)deleteFromDatabase:(NSDictionary *)deletingInfo
{
    NSString *dbFilePath = [self getFullPathForFileInDocDir:[deletingInfo objectForKey:DBFileNameKey]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]) {
        //create database if it does not exists
        FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:dbFilePath];
        
        //open database
        if (![aboutMeDB open]) {
            return;
        }
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", AboutMeTableName, KeyField, [deletingInfo objectForKey:KeyField]];
        
        if (![aboutMeDB executeUpdate:sql]) {
            NSError *error = [aboutMeDB lastError];
            NSLog(@"Error: %@ code: %ld", error.localizedDescription, (long)error.code);
            //[self showErrorAlert:error];
            [aboutMeDB close];
            return;
        }
        
        NSLog(@"data has been successfully deleted from database");
        
        //close database
        [aboutMeDB close];
    }
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
    NSLog(@"%@", error.localizedDescription);
    [alertView show];
}

@end
