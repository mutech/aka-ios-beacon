//
//  AKAStructConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAStructConstantBindingExpression.h"
#import "AKANumberConstantBindingExpression.h"


@implementation AKAStructConstantBindingExpression

+ (NSNumber*) coordinateWithKeys:(NSArray<NSString*>*)keys
                  fromAttributes:(opt_AKABindingExpressionAttributes)attributes
                        required:(BOOL)required
{
    NSNumber* result = nil;
    AKABindingExpression* expression = nil;
    NSString* providedKey = nil;

    for (NSString* key in keys)
    {
        expression = attributes[key];

        if (expression)
        {
            providedKey = key;
            break;
        }
    }

    if ([expression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        result = numberExpression.constant;
    }
    else
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for coordinate %@, expected a numeric constant", NSStringFromClass(expression.class), providedKey];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    if (result == nil && required)
    {
        NSString* message = [NSString stringWithFormat:@"No value for coordinate %@ (valid aliases: %@), expected a numeric constant", keys.firstObject, [keys componentsJoinedByString:@", "]];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    return result;
}

@end
