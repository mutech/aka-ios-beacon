//
//  AKADateFormatterPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 05.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKADateFormatterPropertyBinding.h"
#import "AKAPropertyBinding.h"
#import "AKALocalePropertyBinding.h"
#import "AKACalendarPropertyBinding.h"
#import "AKATimeZonePropertyBinding.h"
#import "AKANSEnumerations.h"

#pragma mark - AKADateFormatterPropertyBinding - Implementation
#pragma mark -

@implementation AKADateFormatterPropertyBinding

+ (AKABindingSpecification*)               specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKADateFormatterPropertyBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"dateStyle":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSDateFormatterStyle" },

                  @"timeStyle":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSDateFormatterStyle" },

                  @"locale":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"bindingType":     [AKALocalePropertyBinding class] },

                  @"calendar":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"bindingType":     [AKACalendarPropertyBinding class] },

                  @"timeZone":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"bindingType":     [AKATimeZonePropertyBinding class] },
                   },
           @"allowUnspecifiedAttributes":   @YES };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    [super registerEnumerationAndOptionTypes];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"NSDateFormatterStyle"
                                                  withValuesByName:[AKANSEnumerations
                                                                    dateFormatterStylesByName]];
    });
}

- (NSFormatter *)defaultFormatter
{
    return [NSDateFormatter new];
}

- (NSFormatter *)createMutableFormatter
{
    return [NSDateFormatter new];
}

@end