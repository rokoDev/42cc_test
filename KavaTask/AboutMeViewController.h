//
//  AboutMeViewController.h
//  KavaTask
//
//  Created by roko on 14.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutMeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSDictionary *userInfo;
//@property (strong, nonatomic) FMDatabase *aboutMeDB;

- (void)createNewUserData;
- (void)placeUI;
- (void)saveToDatabase:(NSString*)databaseFileName;
- (BOOL)loadDataFromDatabase:(NSString*)databaseFileName;

@end
