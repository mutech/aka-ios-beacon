//
//  AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h"

#import "AKAPickerKeyboardTriggerView.h"

#import "AKABindingSpecification.h"
#import "AKABindingProvider_UILabel_textBinding.h"


#pragma mark - AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding - Private Interface
#pragma mark -

@implementation AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding

#pragma mark - Initialization

+ (instancetype)                               sharedInstance
{
    static AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AKABindingProvider_UILabel_textBinding* labelTextBindingProvider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding class],
           @"bindingProviderType":      [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding class],
           @"targetType":               [AKAPickerKeyboardTriggerView class],
           @"expressionType":           @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
           @"attributes":
               @{ @"choices":
                      @{ @"required":        @YES,
                         @"expressionType":  @(labelTextBindingProvider.specification.bindingSourceSpecification.expressionType),
                         @"attributes":      labelTextBindingProvider.specification.bindingSourceSpecification.attributes ? labelTextBindingProvider.specification.bindingSourceSpecification.attributes : @{},
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"choicesBindingExpression"
                         },
                  @"title":
                      @{ @"expressionType":  @(AKABindingExpressionTypeUnqualifiedKeyPath),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"titleBindingExpression",
                         },
                  @"titleForUndefinedValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"titleForOtherValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },

                  @"liveModelUpdates":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"autoActivate":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"KBActivationSequence":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"shouldParticipateInKeyboardActivationSequence"
                         }
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

@end
