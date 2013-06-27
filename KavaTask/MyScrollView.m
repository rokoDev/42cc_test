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
    CGRect rect = self.frame;//CGRectZero;
    
    for(UIView * vv in [self subviews])
    {
        rect = CGRectUnion(rect, vv.frame);
    }
    [self setContentSize:CGSizeMake(rect.size.width, rect.size.height)];
    
    self.contentInset=UIEdgeInsetsMake(0.0,0.0,20.0,0.0);
    self.scrollIndicatorInsets=UIEdgeInsetsMake(0.0,0.0,20.0,0.0);
}

@end
