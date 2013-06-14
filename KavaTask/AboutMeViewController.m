//
//  AboutMeViewController.m
//  KavaTask
//
//  Created by roko on 14.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AboutMeViewController.h"
#import "MyScrollView.h"

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
    UIScrollView *sv = [[MyScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView = sv;
    [[self mainView] addSubview:self.scrollView];
    
    UIImageView *iv  = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView = iv;
    [[self scrollView] addSubview:self.imageView];
    
    if (![self loadDataFromDatabase]) {
        [self createNewUserData];
        [self saveToDatabase];
    }
    [self placeUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)loadDataFromDatabase
{
    return NO;
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
        fieldName.text = key;
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
    
}

@end
