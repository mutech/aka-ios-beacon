//
//  AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.m
//  AKAControls
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
        @{ @"binding":
               @{ @"type":              [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding class],
                  @"bindingProvider":   [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding class]
                  },
           @"target":
               @{ @"type":              [AKAPickerKeyboardTriggerView class]
                  },
           @"source":
               @{
                   @"primaryExpression":
                       @{ @"expressionType": @(AKABindingExpressionTypeAny ^ AKABindingExpressionTypeArray)
                          },
                   @"attributes":
                       @{ @"choices":
                              @{ @"required":        @YES,
                                 @"expressionType":  @(labelTextBindingProvider.specification.bindingSourceSpecification.expressionType),
                                 @"attributes":      labelTextBindingProvider.specification.bindingSourceSpecification.attributes ? labelTextBindingProvider.specification.bindingSourceSpecification.attributes : @{},
                                 @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                                 @"bindingProperty": @"choicesBindingExpression"
                                 },
                          @"title":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeUnqualifiedKeyPath),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                                 @"bindingProperty": @"titleBindingExpression",
                                 },
                          @"titleForUndefinedValue":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeString),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"titleForUndefinedValue"
                                 },
                          @"titleForOtherValue":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeString),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"titleForOtherValue"
                                 },

                          @"liveModelUpdates":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"liveModelUpdates"
                                 },
                          @"autoActivate":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"autoActivate"

                                 },
                          @"KBActivationSequence":
                              @{ @"required":        @NO,
                                 @"expressionType":  @(AKABindingExpressionTypeBoolean),
                                 @"attributes":      @{},
                                 @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                                 @"bindingProperty": @"KBActivationSequence"
                                 }
                          },
                   @"allowUnspecifiedAttributes": @NO
                   }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end
