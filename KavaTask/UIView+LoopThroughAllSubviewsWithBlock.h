//
//  UIView+LoopThroughAllSubviewsWithBlock.h
//  KavaTask
//
//  Created by roko on 18.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BlockWithUserSruff)(UIView *view, BOOL *stop);

@interface UIView (LoopThroughAllSubviewsWithBlock)

- (void)loopThroughAllSubviewsWithBlock:(BlockWithUserSruff)viewAction;

@end
