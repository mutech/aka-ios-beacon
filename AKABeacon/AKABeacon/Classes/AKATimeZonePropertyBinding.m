//
//  AKATimeZonePropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_Protected.h"
#import "AKATimeZonePropertyBinding.h"
#import "AKABindingErrors.h"


@implementation AKATimeZonePropertyBinding

+ (AKABindingSpecification*)               specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKATimeZonePropertyBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeString)
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (BOOL)                              convertSourceValue:(opt_id)sourceValue
                                           toTargetValue:(out_id)targetValueStore
                                                   error:(out_NSError)error
{
    BOOL result = YES;
    NSError* localError = nil;

    if (sourceValue == nil)
    {
        self.syntheticTargetValue = [NSTimeZone localTimeZone];
    }
    else if ([sourceValue isKindOfClass:[NSTimeZone class]])
    {
        self.syntheticTargetValue = sourceValue;
    }
    else if ([sourceValue isKindOfClass:[NSString class]])
    {
        self.syntheticTargetValue = [NSTimeZone timeZoneWithName:(req_NSString)sourceValue];
        if (self.syntheticTargetValue == nil)
        {
            self.syntheticTargetValue = [NSTimeZone timeZoneWithAbbreviation:(req_NSString)sourceValue];
        }
        if (self.syntheticTargetValue == nil)
        {
            NSString* reason = [NSString stringWithFormat:@"Expected a valid time zone name or abbrevation (You can also use an integer for seconds from GMT)"];
            result = NO;
            localError = [AKABindingErrors invalidBinding:self
                                              sourceValue:sourceValue
                                                   reason:reason];
        }
    }
    else if ([sourceValue isKindOfClass:[NSNumber class]])
    {
        self.syntheticTargetValue = [NSTimeZone timeZoneForSecondsFromGMT:[sourceValue integerValue]];
        if (self.syntheticTargetValue == nil)
        {
            NSString* reason = [NSString stringWithFormat:@"Expected a valid integer value representing the number of seconds from GMT (you can also use a string for TZ name or abbreviation)"];
            result = NO;
            localError = [AKABindingErrors invalidBinding:self
                                              sourceValue:sourceValue
                                                   reason:reason];
        }
    }
    else
    {
        AKATypePattern* typePattern = [[AKATypePattern alloc] initWithArrayOfClasses:@[ [NSTimeZone class], [NSString class], [NSNumber class]]];
        localError = [AKABindingErrors invalidBinding:self
                                          sourceValue:sourceValue
                               expectedInstanceOfType:typePattern];
    }

    if (result)
    {
        *targetValueStore = self.syntheticTargetValue;
    }
    else if (error)
    {
        *error = localError;
    }
    else
    {
        @throw [NSException exceptionWithName:@"UnhandledError"
                                       reason:localError.localizedDescription
                                     userInfo:@{ @"error": localError }];
    }

    return result;
}

@end
