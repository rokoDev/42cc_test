//
//  DateField.h
//  KavaTask
//
//  Created by roko on 19.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateField : UITextField

@property (assign, nonatomic) BOOL enableCopy;
@property (assign, nonatomic) BOOL enableCut;
@property (assign, nonatomic) BOOL enablePaste;
@property (assign, nonatomic) BOOL enableSelect;
@property (assign, nonatomic) BOOL enableSelectAll;

@end
