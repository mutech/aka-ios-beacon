//
//  AKABindingProvider_UISlider_valueBinding.m
//  AKAControls
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UISlider_valueBinding.h"
#import "AKABinding_UISlider_valueBinding.h"

@implementation AKABindingProvider_UISlider_valueBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UISlider_valueBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UISlider_valueBinding new];
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
        @{ @"bindingType":              [AKABinding_UISlider_valueBinding class],
           @"bindingProviderType":      [AKABindingProvider_UISlider_valueBinding class],
           @"targetType":               [UISlider class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"minimumValue"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"maximumValue"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end
