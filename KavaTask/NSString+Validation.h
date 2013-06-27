//
//  NSString+Validation.h
//  KavaTask
//
//  Created by roko on 19.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

+ (BOOL) validateEmail:(NSString *)candidate;
+ (BOOL) validateAlphabet:(NSString *)candidate;
+ (BOOL) validateGender:(NSString *)candidate;
+ (BOOL) validateNumeric:(NSString *)candidate;
+ (BOOL) validateURL:(NSString *)candidate;

@end
