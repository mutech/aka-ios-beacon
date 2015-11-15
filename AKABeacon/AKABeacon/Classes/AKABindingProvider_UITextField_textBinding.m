//
//  AKABindingProvider_UITextField_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 28.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UITextField_textBinding.h"
#import "AKABinding_UITextField_textBinding.h"
#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKABinding_AKABinding_dateFormatter.h"
#import "AKABinding_AKABinding_formatter.h"

@implementation AKABindingProvider_UITextField_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UITextField_textBinding* instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UITextField_textBinding new];
    });

    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // see specification defined in AKAKeyboardControlViewBindingProvider:
        NSDictionary* spec = @{
            @"bindingType":          [AKABinding_UITextField_textBinding class],
            @"bindingProviderType":  [AKABindingProvider_UITextField_textBinding class],
            @"targetType":           [UITextField class],
            @"expressionType":       @(AKABindingExpressionTypeAny),
            @"attributes":           @{
                @"numberFormatter":      @{
                    @"bindingProviderType": [AKABindingProvider_AKABinding_numberFormatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"formatter"
                },
                @"dateFormatter":        @{
                    @"bindingProviderType": [AKABindingProvider_AKABinding_dateFormatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"formatter"
                },
                @"formatter":            @{
                    @"bindingProviderType": [AKABindingProvider_AKABinding_formatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"formatter"
                },
                @"editingNumberFormatter": @{
                        @"bindingProviderType": [AKABindingProvider_AKABinding_numberFormatter class],
                        @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                        @"bindingProperty": @"editingFormatter"
                        },
                @"editingDateFormatter": @{
                        @"bindingProviderType": [AKABindingProvider_AKABinding_dateFormatter class],
                        @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                        @"bindingProperty": @"editingFormatter"
                        },
                @"editingFormatter":    @{
                        @"bindingProviderType": [AKABindingProvider_AKABinding_formatter class],
                        @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                        @"bindingProperty": @"editingFormatter"
                        }
            }
        };

        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

@end
