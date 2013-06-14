//
//  AboutMeViewController.m
//  KavaTask
//
//  Created by roko on 14.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "AboutMeViewController.h"

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
    
    UIImage *userPhoto = [UIImage imageNamed:@"userface.png"];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Mikhail", @"Name",
                              @"Zinkovsky", @"Surname",
                              @"17.11.1986", @"Birthday",
                              @"male", @"Sex",
                              @"ukrainian", @"Language",
                              @"mi-han@inbox.ru", @"e-mail",
                              @"Kiev", @"City",
                              nil];
    
    //[self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight];
    
    self.imageView.image = userPhoto;
    
    float horizontalDistanceBetweenNameAndContent = 5;
    float verticalDistanceBetweenLines = 60;
    
    float x = 30, y = 240;
    
    for (id key in userInfo) {
        UILabel *fieldName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 30)];
        fieldName.text = key;
        [self.scrollView addSubview:fieldName];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(x+100+horizontalDistanceBetweenNameAndContent, y, 150, 30)];
        content.text = [userInfo objectForKey:key];
        [self.scrollView addSubview:content];
        y += verticalDistanceBetweenLines;
    }
    
    //CGSize scrollViewSize = [self.scrollView contentSize];
    //scrollViewSize.height = y;
    //self.scrollView.bounds = (CGRect){self.scrollView.bounds.origin, scrollViewSize};
    
    //scrollViewSize.height = MAX(scrollViewSize.height, y);
    //[self.scrollView setContentSize:scrollViewSize];
    
    //CGRect scrollFrame = self.scrollView.frame;
    //scrollFrame.size.height = y;
    //[self.scrollView setFrame:scrollFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize scrollViewSize = [self.scrollView contentSize];
    scrollViewSize.height = 660;
    scrollViewSize.width = 320;
    //self.scrollView.bounds = (CGRect){self.scrollView.bounds.origin, scrollViewSize};
    
    //scrollViewSize.height = MAX(scrollViewSize.height, y);
    [self.scrollView setContentSize:scrollViewSize];
}

@end
