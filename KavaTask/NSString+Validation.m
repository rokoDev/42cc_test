//
//  NSString+Validation.m
//  KavaTask
//
//  Created by roko on 19.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

+ (BOOL) validateEmail:(NSString *)candidate
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL) validateAlphabet:(NSString *)candidate
{
    NSCharacterSet *chs = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *testChs = [NSCharacterSet characterSetWithCharactersInString:candidate];
    return [chs isSupersetOfSet:testChs];
}

+ (BOOL) validateGender:(NSString *)candidate
{
    BOOL retVal = NO;
    if ([candidate isEqualToString:@"male"] || [candidate isEqualToString:@"female"])
        retVal = YES;
    return retVal;
}

+ (BOOL) validateNumeric:(NSString *)candidate
{
    NSCharacterSet *chs = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *testChs = [NSCharacterSet characterSetWithCharactersInString:candidate];
    return [chs isSupersetOfSet:testChs];
}

+ (BOOL) validateURL:(NSString *)candidate
{
    NSURL *candidateURL = [NSURL URLWithString:candidate];
    return (candidateURL && candidateURL.scheme && candidateURL.host);
}

@end
