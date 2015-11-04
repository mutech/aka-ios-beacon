//
//  AKAEmailValidator.m
//  AKABeacon
//
//  Created by Michael Utech on 04.05.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAEmailValidator.h"
#import "AKAControlsErrors_Internal.h"

#define UINT8_REGEX \
    @"(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
#define NONPRINT_REGEX \
    @"[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]"
#define NONPRINT_HOST_REGEX \
    @"[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]"
#define BACKSLASHED_PART_REGEX \
    @"\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f]"
#define MAILBOX_CHAR_REGEX \
    @"[a-z0-9!#$%&'*+/=?^_`{|}~-]"
#define HOST_CHARS_REGEX \
    @"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"

#define MAILBOX_REGEX \
    @"(?:" \
    MAILBOX_CHAR_REGEX @"+(?:\\." MAILBOX_CHAR_REGEX @"+)*" \
    @"|" \
    @"\"(?:" NONPRINT_REGEX @"|" BACKSLASHED_PART_REGEX @")*\"" \
    @")"


#define HOST_REGEX \
    @"(?:(?:" HOST_CHARS_REGEX @"\\.)+" HOST_CHARS_REGEX \
    @"|\\[(?:" UINT8_REGEX @"\\.){3}(?:" UINT8_REGEX \
    @"|[a-z0-9-]*[a-z0-9]:(?:" \
    NONPRINT_HOST_REGEX @"|" BACKSLASHED_PART_REGEX @")+)\\])"

#define EMAIL_REGEX \
    @"^" \
    MAILBOX_REGEX \
    @"@" \
    HOST_REGEX \
    @"$"

@implementation AKAEmailValidator

+ (NSRegularExpression*)emailRegularExpression
{
    static NSRegularExpression* instance = nil;
    static dispatch_once_t onceToken;
    __block NSError* error = nil;
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
    dispatch_once(&onceToken, ^{
        NSString* pattern = EMAIL_REGEX;
        instance = [NSRegularExpression regularExpressionWithPattern:pattern
                                                             options:options
                                                               error:&error];
    });
    NSAssert(instance != nil && error == nil, @"Invalid regular expression %@: %@", EMAIL_REGEX, error.description);
    return instance;
}

- (BOOL)validateModelValue:(id)modelValue
                     error:(NSError *__autoreleasing *)error
{
    BOOL result = NO;

    if ([modelValue isKindOfClass:[NSString class]])
    {
        NSString* text = modelValue;
        NSRange range = NSMakeRange(0, text.length);
        NSRegularExpression* regex = [self.class emailRegularExpression];
        NSTextCheckingResult* match = [regex firstMatchInString:text
                                                        options:NSMatchingAnchored range:range];
        result = (match != nil);
        if (!result && error != nil)
        {
            *error = [AKAControlsErrors errorForInvalidEmailAddress:text
                                              withRegularExpression:EMAIL_REGEX];
        }
    }
    else
    {
        if (error != nil)
        {
            *error = [AKAControlsErrors errorForInvalidEmailAddressValueType:modelValue];
        }
    }
    return result;
}

@end
