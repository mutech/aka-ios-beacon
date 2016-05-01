//
//  AKATableViewCellFactoryArrayPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCellFactoryPropertyBinding.h"
#import "AKATableViewCellFactoryArrayPropertyBinding.h"


@implementation AKATableViewCellFactoryArrayPropertyBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  [AKATableViewCellFactoryArrayPropertyBinding self],
           @"expressionType":               @(AKABindingExpressionTypeArray),
           @"arrayItemBindingType":         [AKATableViewCellFactoryPropertyBinding class]
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

@end