//
//  AKABinding_AKABinding_numberFormatter.m
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKANSEnumerations.h"


#pragma mark - AKABinding_AKABinding_numberFormatter  - Implementation
#pragma mark -

@implementation AKABinding_AKABinding_numberFormatter

+ (AKABindingSpecification*)                 specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":         self,
           @"targetType":          [AKAProperty class],
           @"expressionType":      @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"numberStyle":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterStyle" },

                  @"roundingMode":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterRoundingMode" },

                  @"paddingPosition":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSNumberFormatterPadPosition" },

                  @"locale":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseManually),
                         @"expressionType":  @(AKABindingExpressionTypeString) }, },

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

- (NSDictionary<NSString*, id (^)(id)>*)configurationValueConvertersByPropertyName
{
    static NSDictionary<NSString*, id (^)(id)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = @{ @"formattingContext":^id (id value) {
                        return [AKANSEnumerations formattingContextForObject:value];
                    },
                    @"locale":           ^id (id value) {
                        return [AKANSEnumerations localeForObject:value];
                    },
                    /*@"numberStyle":      ^id (id value) {
                        return [AKANSEnumerations numberFormatterStyleForObject:value];
                    },
                    @"roundingMode":     ^id (id value) {
                        return [AKANSEnumerations numberFormatterRoundingModeForObject:value];
                    },
                    @"paddingPosition":  ^id (id value) {
                        return [AKANSEnumerations numberFormatterPadForObject:value];
                    },*/ };
    });

    return result;
}

@end
