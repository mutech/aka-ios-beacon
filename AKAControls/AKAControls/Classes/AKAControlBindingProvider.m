//
//  AKAControlBindingProvider.m
//  AKAControls
//
//  Created by Michael Utech on 15.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlBindingProvider.h"
#import "AKAControlBinding.h"
#import "AKAControl.h"

@implementation AKAControlBindingProvider

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKAControlBindingProvider* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKAControlBindingProvider new];
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
        @{ @"bindingType":          [AKAControlBinding class],
           @"bindingProviderType":  [AKAControlBindingProvider class],
           @"targetType":           [AKAControl class],
           @"expressionType":       @(AKABindingExpressionTypeClass | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"name":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         },
                  @"tags":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                         @"bindingProperty": @"serializedTags",
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end
