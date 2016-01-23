//
//  AKATableViewDataSourcePropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewDataSourcePropertyBinding.h"

@interface AKATableViewDataSourcePropertyBinding()

@end

@implementation AKATableViewDataSourcePropertyBinding

+ (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKATableViewDataSourcePropertyBinding class],
           @"expressionType":       @(AKABindingExpressionTypeArray),
           @"attributes":
               @{
                   @"cellMapping": @{
                           @"expressionType":  @(AKABindingExpressionTypeArray),
                           @"use":             @(AKABindingAttributeUseManually),
                           // TODO: arrayItems/<specification> instead of @"arrayItemBindingType":
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
