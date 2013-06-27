//
//  UIView+LoopThroughAllSubviewsWithBlock.m
//  KavaTask
//
//  Created by roko on 18.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "UIView+LoopThroughAllSubviewsWithBlock.h"

@implementation UIView (LoopThroughAllSubviewsWithBlock)

- (void)loopThroughAllSubviewsWithBlock:(BlockWithUserSruff)viewAction
{
    //view action block - freedom to the caller
    BOOL stop = NO;
    
    viewAction(self, &stop);
    
    if (stop) {
        return;
    }
    
    for (UIView *subview in self.subviews) {
        [subview loopThroughAllSubviewsWithBlock:viewAction];
    }
}

@end
