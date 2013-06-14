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
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    self.aboutMeDB = [FMDatabase databaseWithPath:[appDelegate getFullPathForFileInDocDir:AboutMeDatabaseFileName]];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    UIScrollView *sv = [[MyScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView = sv;
    [[self mainView] addSubview:self.scrollView];
    
    UIImageView *iv  = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView = iv;
    [[self scrollView] addSubview:self.imageView];
    
    if (![self loadDataFromDatabase]) {
        NSLog(@"couldn't load data from database");
        [self createNewUserData];
        [self saveToDatabase];
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
    CGRect scrollViewFrame= self.scrollView.frame;
    self.imageView.frame = CGRectMake((scrollViewFrame.size.width-self.imageView.image.size.width)/2, scrollViewFrame.size.height/20, self.imageView.image.size.width, self.imageView.image.size.height);
    [[self scrollView] addSubview:self.imageView];
    
    float horizontalDistanceBetweenNameAndContent = 5;
    float verticalDistanceBetweenLines = 60;
    
    float x = 30, y = 240;
    
    for (id key in self.userInfo) {
        UILabel *fieldName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 30)];
        fieldName.text = [NSString stringWithFormat:@"%@:", key];
        [self.scrollView addSubview:fieldName];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(x+100+horizontalDistanceBetweenNameAndContent, y, 150, 30)];
        content.text = [self.userInfo objectForKey:key];
        [self.scrollView addSubview:content];
        y += verticalDistanceBetweenLines;
    }
    
    [(MyScrollView*)[self scrollView] adjustContentSize];
}

- (void)saveToDatabase
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[appDelegate getFullPathForFileInDocDir:AboutMeDatabaseFileName]];
    
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

- (BOOL)loadDataFromDatabase
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //create database if it does not exists
    FMDatabase *aboutMeDB = [FMDatabase databaseWithPath:[appDelegate getFullPathForFileInDocDir:AboutMeDatabaseFileName]];
    
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
