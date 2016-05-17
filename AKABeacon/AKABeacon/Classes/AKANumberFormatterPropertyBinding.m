//
//  AKANumberFormatterPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKANullability.h"

#import "AKANumberFormatterPropertyBinding.h"
#import "AKANSEnumerations.h"
#import "AKALocalePropertyBinding.h"

#pragma mark - AKANumberFormatterPropertyBinding  - Implementation
#pragma mark -

@implementation AKANumberFormatterPropertyBinding

+ (AKABindingSpecification*)                 specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":         [AKANumberFormatterPropertyBinding class],
           @"targetType":          [AKAProperty class],
           @"expressionType":      @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"numberStyle":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterStyle" },

                  @"roundingMode":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterRoundingMode" },

                  @"paddingPosition":
                      @{ @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterPadPosition" },

                  @"locale":
                      @{ @"use":             @(AKABindingAttributeUseManually),
                         @"bindingType":     [AKALocalePropertyBinding class] },
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

        [AKABindingExpressionSpecification registerEnumerationType:@"NSNumberFormatterStyle"
                                                  withValuesByName:[AKANSEnumerations
                                                                    numberStylesByName]];
        [AKABindingExpressionSpecification registerEnumerationType:@"NSNumberFormatterRoundingMode"
                                                  withValuesByName:[AKANSEnumerations
                                                                    roundingModesByName]];
        [AKABindingExpressionSpecification registerEnumerationType:@"NSNumberFormatterPadPosition"
                                                  withValuesByName:[AKANSEnumerations
                                                                    padPositionsByName]];
    });
}

- (NSFormatter *)defaultFormatter
{
    return [NSNumberFormatter new];
}

- (NSFormatter*)createMutableFormatter
{
    return [NSNumberFormatter new];
}

@end
