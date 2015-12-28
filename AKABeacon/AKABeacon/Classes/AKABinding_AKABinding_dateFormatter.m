//
//  AKABinding_AKABinding_dateFormatter.m
//  AKABeacon
//
//  Created by Michael Utech on 05.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABinding_AKABinding_dateFormatter.h"
#import "AKAPropertyBinding.h"
#import "AKANSEnumerations.h"

#pragma mark - AKABinding_AKABinding_dateFormatter - Private Interface
#pragma mark -

@interface AKABinding_AKABinding_dateFormatter ()

@property(nonatomic, nonnull)           NSDateFormatter*                    dateFormatter;
@property(nonatomic, nonnull, readonly) NSDictionary<NSString*, id (^)(id)>* configurationValueConvertersByPropertyName;

@end


#pragma mark - AKABinding_AKABinding_dateFormatter - Implementation
#pragma mark -

@implementation AKABinding_AKABinding_dateFormatter

+ (AKABindingSpecification*)               specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  self,
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"dateStyle":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSDateFormatterStyle" },

                  @"timeStyle":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSDateFormatterStyle" },

                  @"locale":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseIgnore),
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

- (NSDictionary<NSString*, id (^)(id)>*) configurationValueConvertersByPropertyName
{
    static NSDictionary<NSString*, id (^)(id)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"locale":           ^id (id value) {
                   return [AKANSEnumerations localeForObject:value];
               },
               @"calendar":         ^id (id value) {
                   return [AKANSEnumerations calendarForObject:value];
               },
               @"timeZone":         ^id (id value) {
                   return [AKANSEnumerations timeZoneForObject:value];
               }, };
    });

    return result;
}

@end