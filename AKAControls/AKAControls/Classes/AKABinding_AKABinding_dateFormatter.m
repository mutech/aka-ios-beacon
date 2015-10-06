//
//  AKABinding_AKABinding_dateFormatter.m
//  AKAControls
//
//  Created by Michael Utech on 05.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABinding_AKABinding_dateFormatter.h"
#import "AKAPropertyBinding.h"
#import "AKANSEnumerations.h"

#pragma mark - AKABindingProvider_AKABinding_dateFormatter - Implementation
#pragma mark -

@implementation AKABindingProvider_AKABinding_dateFormatter

#pragma mark - Initialization

+ (instancetype)                            sharedInstance
{
    static AKABindingProvider_AKABinding_dateFormatter* instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKABinding_dateFormatter new];
    });

    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification*)               specification
{
    Class bindingType = [AKABinding_AKABinding_dateFormatter class];
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


#pragma mark - AKABinding_AKABinding_dateFormatter - Private Interface
#pragma mark -

@interface AKABinding_AKABinding_dateFormatter ()

@property(nonatomic, nonnull)           NSDateFormatter*                    dateFormatter;
@property(nonatomic, nonnull, readonly) NSDictionary<NSString*, id (^)(id)>* configurationValueConvertersByPropertyName;

@end


#pragma mark - AKABinding_AKABinding_dateFormatter - Implementation
#pragma mark -

@implementation AKABinding_AKABinding_dateFormatter

#pragma mark - Enumeration Name Value Mapping

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
            @{ @"dateStyle":        ^id (id value) {
                   return [AKANSEnumerations dateFormatterStyleForObject:value];
               },
               @"timeStyle":        ^id (id value) {
                   return [AKANSEnumerations dateFormatterStyleForObject:value];
               },
               @"locale":           ^id (id value) {
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