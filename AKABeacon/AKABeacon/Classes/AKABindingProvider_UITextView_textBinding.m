//
//  AKABindingProvider_UITextView_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UITextView_textBinding.h"

#import "AKABinding_UITextView_textBinding.h"

@implementation AKABindingProvider_UITextView_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UITextView_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UITextView_textBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Inherits specification of AKAKeyboardControlViewBindingProvider:
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UITextView_textBinding class],
           @"bindingProviderType":  [AKABindingProvider_UITextView_textBinding class],
           @"targetType":           [UITextView class] };

        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
