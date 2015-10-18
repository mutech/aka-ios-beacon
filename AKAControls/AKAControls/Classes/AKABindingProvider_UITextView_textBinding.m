//
//  AKABindingProvider_UITextView_textBinding.m
//  AKAControls
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingProvider_UITextView_textBinding.h"

#import "AKABinding_UITextView_textBinding.h"

@implementation AKABindingProvider_UITextView_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UITextView_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UITextView_textBinding new];
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
        @{ @"bindingType":          [AKABinding_UITextView_textBinding class],
           @"bindingProviderType":  [AKABindingProvider_UITextView_textBinding class],
           @"targetType":           [UITextView class],
           @"expressionType":       @(AKABindingExpressionTypeAny ^ AKABindingExpressionTypeArray),
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
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end
