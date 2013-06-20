//
//  DateField.m
//  KavaTask
//
//  Created by roko on 19.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "DateField.h"

@implementation DateField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _enableCopy = _enableCut = _enablePaste = _enableSelect = _enableSelectAll = YES;
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
        return _enableCopy;
    if (action == @selector(cut:))
        return _enableCut;
    if (action == @selector(paste:))
        return _enablePaste;
    if (action == @selector(select:))
        return _enableSelect;
    if (action == @selector(selectAll:))
        return _enableSelectAll;
    return [super canPerformAction:action withSender:sender];
}

@end
