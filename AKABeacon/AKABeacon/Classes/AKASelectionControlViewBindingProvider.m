//
//  AKASelectionControlViewBindingProvider.m
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"
#import "AKASelectionControlViewBindingProvider.h"
#import "AKABindingProvider_UILabel_textBinding.h"

@implementation AKASelectionControlViewBindingProvider

// This is an abstract binding provider, so it does not defined a sharedInstance method.

- (AKABindingSpecification *)                   specification
{
    AKABindingProvider_UILabel_textBinding* labelTextBindingProvider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKAControlViewBinding class],
           @"bindingProviderType":      [AKABindingProvider class],
           @"targetType":               [UIView class],
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
                         }
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

@end
