//
//  AKAKeyboardControlViewBindingProvider.m
//  AKABeacon
//
//  Created by Michael Utech on 11.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControlViewBindingProvider.h"
#import "AKAKeyboardControlViewBinding.h"

@implementation AKAKeyboardControlViewBindingProvider

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKAKeyboardControlViewBindingProvider* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKAKeyboardControlViewBindingProvider new];
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
        @{ @"bindingType":          [AKAKeyboardControlViewBinding class],
           @"bindingProviderType":  [AKAKeyboardControlViewBindingProvider class],
           @"targetType":           [UIResponder class],
           @"expressionType":       @( (AKABindingExpressionTypeAny
                                        & ~AKABindingExpressionTypeArray) ),
           @"attributes":
               @{ @"liveModelUpdates":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty)
                         },
                  @"autoActivate":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty)
                         },
                  @"KBActivationSequence":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"shouldParticipateInKeyboardActivationSequence"
                         }
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end
