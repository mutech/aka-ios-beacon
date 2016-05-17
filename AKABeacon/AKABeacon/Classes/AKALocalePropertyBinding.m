//
//  AKALocalePropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKABinding_Protected.h"
#import "AKALocalePropertyBinding.h"
#import "AKABindingErrors.h"


@implementation AKALocalePropertyBinding

+ (AKABindingSpecification*)               specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKALocalePropertyBinding class],
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
        self.syntheticTargetValue = [NSLocale currentLocale];
    }
    else if ([sourceValue isKindOfClass:[NSLocale class]])
    {
        self.syntheticTargetValue = sourceValue;
    }
    else if ([sourceValue isKindOfClass:[NSString class]])
    {
        self.syntheticTargetValue = [NSLocale localeWithLocaleIdentifier:(NSString*)sourceValue];
        if (self.syntheticTargetValue == nil)
        {
            NSString* reason = [NSString stringWithFormat:@"Expected a valid locale identifier"];
            result = NO;
            localError = [AKABindingErrors invalidBinding:self
                                              sourceValue:sourceValue
                                                   reason:reason];
        }
    }
    else
    {
        AKATypePattern* typePattern = [[AKATypePattern alloc] initWithArrayOfClasses:@[[NSLocale class],
                                                                                       [NSString class]]];
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
