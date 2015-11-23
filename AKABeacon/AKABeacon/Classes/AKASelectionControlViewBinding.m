//
//  AKASelectionControlViewBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"
#import "AKASelectionControlViewBinding.h"
#import "AKABinding_UILabel_textBinding.h"

@implementation AKASelectionControlViewBinding

// This is an abstract binding provider, so it does not defined a sharedInstance method.

+ (AKABindingSpecification *)                   specification
{
    req_AKABindingSpecification labelBindingSpec = [AKABinding_UILabel_textBinding specification];

    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKAControlViewBinding class],
           @"targetType":               [UIView class],
           @"expressionType":           @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
           @"attributes":
               @{ @"choices":
                      @{ @"required":        @YES,
                         @"expressionType":  @(labelBindingSpec.bindingSourceSpecification.expressionType),
                         @"attributes":      labelBindingSpec.bindingSourceSpecification.attributes ? labelBindingSpec.bindingSourceSpecification.attributes : @{},
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
