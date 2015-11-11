//
//  AKABindingProvider_UIStepper_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UIStepper_valueBinding.h"
#import "AKABinding_UIStepper_valueBinding.h"

@implementation AKABindingProvider_UIStepper_valueBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UIStepper_valueBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UIStepper_valueBinding new];
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
        @{ @"bindingType":              [AKABinding_UIStepper_valueBinding class],
           @"bindingProviderType":      [AKABindingProvider_UIStepper_valueBinding class],
           @"targetType":               [UIStepper class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"minimumValueExpression"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"maximumValueExpression"
                         },
                  @"stepValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"stepValueExpression"
                         },
                  @"autorepeat":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"continuous":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"wraps":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
