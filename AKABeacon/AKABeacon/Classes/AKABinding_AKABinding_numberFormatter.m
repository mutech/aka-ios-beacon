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

#pragma mark - AKABindingProvider_AKABinding_numberFormatter  - Private Interface
#pragma mark -

@implementation AKABindingProvider_AKABinding_numberFormatter

#pragma mark - Initialization

+ (instancetype)                            sharedInstance
{
    static AKABindingProvider_AKABinding_numberFormatter* instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKABinding_numberFormatter new];
    });

    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification*)                 specification
{
    Class bindingType = [AKABinding_AKABinding_numberFormatter class];
    Class providerType = self.class;

    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
            @{ @"bindingType":                  bindingType,
               @"bindingProviderType":          providerType,
               @"targetType":                   [AKAProperty class],
               @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
               @"allowUnspecifiedAttributes":   @YES };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });

    return result;
}

@end


#pragma mark - AKABinding_AKABinding_numberFormatter  - Implementation
#pragma mark -

@implementation AKABinding_AKABinding_numberFormatter

#pragma mark - Abstract Method Implementation

- (NSFormatter*)createMutableFormatter
{
    return [NSNumberFormatter new];
}

- (NSDictionary<NSString*, id (^)(id)>*)configurationValueConvertersByPropertyName
{
    static NSDictionary<NSString*, id (^)(id)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"numberStyle":      ^id (id value) {
                   return [AKANSEnumerations numberFormatterStyleForObject:value];
               },
               @"locale":           ^id (id value) {
                   return [AKANSEnumerations localeForObject:value];
               },
               @"roundingMode":     ^id (id value) {
                   return [AKANSEnumerations numberFormatterRoundingModeForObject:value];
               },
               @"formattingContext":^id (id value) {
                   return [AKANSEnumerations formattingContextForObject:value];
               },
               @"paddingPosition":  ^id (id value) {
                   return [AKANSEnumerations numberFormatterPadForObject:value];
               }, };
    });

    return result;
}

@end
