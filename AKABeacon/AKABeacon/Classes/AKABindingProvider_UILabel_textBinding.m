//
//  AKABindingProvider_UILabel_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABindingProvider_UILabel_textBinding.h"
#import "AKABinding_UILabel_textBinding.h"

#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKABinding_AKABinding_dateFormatter.h"

#pragma mark - AKABindingProvider_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABindingProvider_UILabel_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UILabel_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UILabel_textBinding new];
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
        @{ @"bindingType":          [AKABinding_UILabel_textBinding class],
           @"bindingProviderType":  [AKABindingProvider_UILabel_textBinding class],
           @"targetType":           [UILabel class],
           @"expressionType":       @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
           @"attributes":
               @{ @"numberFormatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_numberFormatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"numberFormatter"
                         },
                  @"dateFormatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_dateFormatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"dateFormatter"
                         },
                  @"formatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_formatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"formatter"
                         },
                  @"textForUndefinedValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForUndefinedValue"
                         },
                  @"textForYes":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForYes"
                         },
                  @"textForNo":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForNo"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
