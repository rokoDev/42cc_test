//
//  AboutMeViewController.m
//  KavaTask
//
//  Created by roko on 14.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AboutMeViewController.h"
#import "MyScrollView.h"
#import "AppDelegate.h"
#import "FMDatabase.h"

@interface AboutMeViewController ()

@end

@implementation AboutMeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    fullScreenRect.origin = CGPointZero;
    UIScrollView *sv = [[MyScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView = sv;
    [[self mainView] addSubview:self.scrollView];
    
    UIImageView *iv  = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView = iv;
    [[self scrollView] addSubview:self.imageView];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (![self loadDataFromDatabase:AboutMeTableName]) {
        NSLog(@"couldn't load data from database");
        [self createNewUserData];
        [self saveToDatabase:AboutMeTableName];
    }
    else {
        NSLog(@"data has been successfully loaded form database");
    }
    [self placeUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createNewUserData
{
    UIImage *userPhoto = [UIImage imageNamed:@"userface.png"];
    self.imageView.image = userPhoto;
    self.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Mikhail", @"Name",
                     @"Zinkovsky", @"Surname",
                     @"17.11.1986", @"Birthday",
                     @"male", @"Sex",
                     @"ukrainian", @"Language",
                     @"mi-han@inbox.ru", @"e-mail",
                     @"Kiev", @"City",
                     nil];
}

- (void)placeUI
{
    UIScrollView *sv = self.scrollView;
    
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sv]|"
                                             options:0 metrics:nil
                                               views:@{@"sv":sv}]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sv]|"
                                             options:0 metrics:nil
                                               views:@{@"sv":sv}]];
    
    sv.scrollEnabled = YES;
    sv.alwaysBounceVertical = YES;
    
    
    UIImageView *iv = self.imageView;
    
    [sv addSubview:iv];
    
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    [sv addConstraint:[NSLayoutConstraint constraintWithItem:iv
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:sv
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0]];
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[iv]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"iv":iv}]];
    
    
    UILabel* previousLab = nil;
    for (id key in self.userInfo) {
        UILabel *fieldName = [UILabel new];
        fieldName.translatesAutoresizingMaskIntoConstraints = NO;
        fieldName.text = [NSString stringWithFormat:@"%@:", key];
        [sv addSubview:fieldName];
        [sv addConstraint:[NSLayoutConstraint constraintWithItem:fieldName
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:sv
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1.0
                                                        constant:0]];
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iv]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":fieldName, @"iv":iv}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":fieldName, @"prev":previousLab}]];
        }
        
        UILabel *content = [UILabel new];
        content.translatesAutoresizingMaskIntoConstraints = NO;
        content.text = [self.userInfo objectForKey:key];
        [sv addSubview:content];
        [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[fieldName]-[lab]"
                                                                   options:0 metrics:nil
                                                                     views:@{@"lab":content,@"fieldName":fieldName}]];
        
        if (!previousLab) { // first one, pin to top
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iv]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":content, @"iv":iv}]];
        } else { // all others, pin to previous
            [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-(50)-[lab]"
                                                                       options:0 metrics:nil
                                                                         views:@{@"lab":content, @"prev":previousLab}]];
        }
        
        previousLab = fieldName;
    }
    
    [sv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lab]-(50)-|"
                                                               options:0 metrics:nil
                                                                 views:@{@"lab":previousLab}]];
    
}

- (void)saveToDatabase:(NSString*)databaseFileName
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[appDelegate getFullPathForFileInDocDir:databaseFileName]];
    
    //open database
    if (![aboutMeDB open]) {
        return;
    }
    
    //create table if it does not exists
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT UNIQUE, '%@' BLOB, '%@' BLOB)", AboutMeTableName, KeyField, PhotoField, InfoField];
    if (![aboutMeDB executeUpdate:sql]) {
        NSError *error = [aboutMeDB lastError];
        NSLog(@"Error: %@ code: %ld", error.localizedDescription, (long)error.code);
        //[appDelegate showErrorAlert:error];
        return;
    }
    
    //save data to the database
    sql = [NSString stringWithFormat:@"INSERT INTO %@ ('%@', '%@', '%@') VALUES (?, ?, ?)", AboutMeTableName, KeyField, PhotoField, InfoField];
    NSData *photoData = UIImagePNGRepresentation(self.imageView.image);
    NSData *infoData = [NSPropertyListSerialization dataWithPropertyList:self.userInfo
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:NULL];
    if (![aboutMeDB executeUpdate:sql, MyIdInDatabase, photoData, infoData]) {
        NSError *error = [aboutMeDB lastError];
        NSLog(@"Error: %@ code: %ld", error.localizedDescription, (long)error.code);
        //[appDelegate showErrorAlert:error];
        return;
    }
    
    NSLog(@"data has been saved to database");
    
    //close database
    [aboutMeDB close];
}

- (BOOL)loadDataFromDatabase:(NSString*)databaseFileName
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[appDelegate getFullPathForFileInDocDir:databaseFileName]];
    
    //open database
    if (![aboutMeDB open]) {
        return NO;
    }
    
    //read database
    NSString* sqliteQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", AboutMeTableName, KeyField, MyIdInDatabase];
    FMResultSet *result = [aboutMeDB executeQuery:sqliteQuery];
    
    if ([result next]) {
        NSData *photoData = [result dataForColumn:PhotoField];
        NSData *infoData = [result dataForColumn:InfoField];
        
        if (!photoData || !infoData)
            return NO;
        UIImage *userPhoto = [UIImage imageWithData:photoData];
        self.imageView.image = userPhoto;
        
        NSPropertyListFormat plistFormat;
        self.userInfo = [NSPropertyListSerialization propertyListWithData:infoData
                                                                  options:0
                                                                   format:&plistFormat
                                                                    error:NULL];
        return YES;
    }
    else
        return NO;
}

@end
