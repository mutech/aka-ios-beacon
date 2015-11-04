//
//  AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKADatePickerKeyboardTriggerView.h"

@implementation AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding

#pragma mark - Initialization

+ (instancetype)                               sharedInstance
{
    static AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding* instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding new];
    });

    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification*)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
            @"bindingType":              [AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding class],
            @"bindingProviderType":      [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding class],
            @"targetType":               [AKADatePickerKeyboardTriggerView class],
            @"expressionType":           @(AKABindingExpressionTypeAnyKeyPath),// TODO: create a date (constant-) type
            @"attributes": @{
                @"liveModelUpdates": @{
                    @"expressionType":  @(AKABindingExpressionTypeBoolean),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                },
                @"autoActivate": @{
                    @"expressionType":  @(AKABindingExpressionTypeBoolean),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                },
                @"KBActivationSequence": @{
                    @"expressionType":  @(AKABindingExpressionTypeBoolean),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty": @"shouldParticipateInKeyboardActivationSequence"
                }
            }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });

    return result;
}

@end
