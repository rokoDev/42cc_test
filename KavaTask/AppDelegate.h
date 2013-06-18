//
//  AppDelegate.h
//  KavaTask
//
//  Created by roko on 13.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const AboutMeDatabaseFileName;
extern NSString *const AboutMeTableName;
extern NSString *const KeyField;
extern NSString *const PhotoField;
extern NSString *const InfoField;
extern NSString *const MyIdInDatabase;

extern NSString *const DBFileNameKey;

extern NSString *const SCSessionStateChangedNotification;
extern NSString *const LoginedViewControllerNotification;
extern NSString *const DefaultUserImagePath;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)loginedVCDidAppear;
- (void)showLoginView;
- (void)openSession;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)getFullPathForFileInDocDir:(NSString*)fileName;
- (void)showErrorAlert:(NSError *)error;

- (void)saveToDatabase:(NSDictionary*)savingInfo;
- (BOOL)loadDataFromDatabase:(NSMutableDictionary*)loadingInfo;
- (void)deleteFromDatabase:(NSDictionary*)deletingInfo;

@end
