//
//  AKABinding_UILabel_styleBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 15.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UILabel_styleBinding.h"
#import "AKAPropertyBinding.h"

@implementation AKABinding_UILabel_styleBinding

+ (req_AKABindingSpecification)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UILabel_styleBinding class],
           @"targetType":           [UIView class],
           @"expressionType":       @(AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"textColor":
                      @{ @"bindingType":    [AKAPropertyBinding class],
                         @"expressionType": @(AKABindingExpressionTypeUIColor),
                         @"use":             @(AKABindingAttributeUseBindToTargetProperty)
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
