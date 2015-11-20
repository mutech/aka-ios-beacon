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


    AKABindingSpecification* selectionSpecification =
        [AKASelectionControlViewBindingProvider.sharedInstance specification];
    AKABindingSpecification* baseSpecification =
        [[super specification] specificationExtendedWith:selectionSpecification];

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding class],
           @"bindingProviderType":      [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding class],
           @"targetType":               [AKAPickerKeyboardTriggerView class],
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:baseSpecification];
    });

    return result;
}

@end
