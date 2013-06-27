//
//  AppDelegate.h
//  KavaTask
//
//  Created by roko on 13.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const AboutMeDatabaseFileName;
extern NSString *const AboutMeTableName;
extern NSString *const KeyField;
extern NSString *const PhotoField;
extern NSString *const InfoField;
extern NSString *const MyIdInDatabase;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)getFullPathForFileInDocDir:(NSString*)fileName;
- (void)showErrorAlert:(NSError *)error;

@end
