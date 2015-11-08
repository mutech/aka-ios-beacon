//
//  AKABindingProvider_UISwitch_stateBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UISwitch_stateBinding.h"
#import "AKABinding_UISwitch_stateBinding.h"

#pragma mark - AKABindingProvider_UISwitch_stateBinding
#pragma mark -


@implementation AKABindingProvider_UISwitch_stateBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UISwitch_stateBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UISwitch_stateBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UISwitch_stateBinding class],
           @"bindingProviderType":      [AKABindingProvider_UISwitch_stateBinding class],
           @"targetType":               [UISwitch class],
           @"expressionType":           @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray)
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end


