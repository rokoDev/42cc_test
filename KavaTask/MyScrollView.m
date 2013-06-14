//
//  MyScrollView.m
//  KavaTask
//
//  Created by roko on 14.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "MyScrollView.h"

@implementation MyScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setBackgroundColor:<#(UIColor *)#>:[UIColor whiteColor]];
        NSLog(@"init MyScrollView");
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)adjustContentSize
{
    NSLog(@"adjustContentSize");
    CGRect rect = CGRectZero;
    
    for(UIView * vv in [self subviews])
    {
        rect = CGRectUnion(rect, vv.frame);
    }
    //[self setFrame:CGRectMake(0, 0, 640, 960)];
    [self setContentSize:CGSizeMake(rect.size.width, rect.size.height)];
    //[self setContentInset:UIEdgeInsetsMake(0, 0, 100, 0)];
    
    self.contentInset=UIEdgeInsetsMake(30.0,0.0,35.0,0.0);
    self.scrollIndicatorInsets=UIEdgeInsetsMake(30.0,0.0,35.0,0.0);
}

@end
